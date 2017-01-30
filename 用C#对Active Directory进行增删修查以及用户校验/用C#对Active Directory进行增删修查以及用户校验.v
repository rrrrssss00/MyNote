用C#对Active Directory进行增删修查以及用户校验

博客分类：
C#
CC++C#ExchangeBlog 
本文引自：http://hi.baidu.com/zhizhesky/blog/item/f4b70ae90122eb33b80e2db3.html 

用C#对Active Directory进行增删修查以及用户校验2010-05-20 14:27http://blog.sina.com.cn/s/blog_53864cba0100i4rz.html 

第一个类，获取AD实例类； 

AdHerlp.cs 

public static class AdHerlp 
{ 
#region 创建AD连接 
/// <summary> 
/// 创建AD连接 
/// </summary> 
/// <returns></returns> 
public static DirectoryEntry GetDirectoryEntry() 
{ 
DirectoryEntry de = new DirectoryEntry(); 
de.Path = "LDAP://qjyczsgl/CN=Users,DC=qjyczsgl,DC=com"; 
de.Username = @"qjyczsgl\zsgl"; 
de.Password = "qjyczsgl"; 
return de; 
} 
#endregion 

#region 获取目录实体集合 
/// <summary> 
/// 
/// </summary> 
/// <param name="DomainReference"></param> 
/// <returns></returns> 
public static DirectoryEntry GetDirectoryEntry(string DomainReference) 
{ 
DirectoryEntry entry = new DirectoryEntry("LDAP://qjyczsgl" + DomainReference, "zsgl", "qjyczsgl", AuthenticationTypes.Secure); 
return entry; 
} 
#endregion 
} 

AD操作类 

myDirectory.cs 

class myDirectory 
{ 

/// <summary> 
/// 判断用户是否存在 
/// </summary> 
/// <param name="UserName"></param> 
/// <returns></returns> 
public bool UserExists(string UserName) 
{ 
DirectoryEntry de = AdHerlp.GetDirectoryEntry(); 
DirectorySearcher deSearch = new DirectorySearcher(); 
deSearch.SearchRoot = de; 
deSearch.Filter = "(&(objectClass=user) (cn=" + UserName + "))"; 
SearchResultCollection results = deSearch.FindAll(); 
if (results.Count == 0) 
{ 
return false; 
} 
else 
{ 
return true; 
} 
} 
/// <summary> 
/// 修改用户属性 
/// </summary> 
/// <param name="de"></param> 
/// <param name="PropertyName"></param> 
/// <param name="PropertyValue"></param> 
public static void SetProperty(DirectoryEntry de, string PropertyName, string PropertyValue) 
{ 
if (PropertyValue != null) 
{ 
if (de.Properties.Contains(PropertyName)) 
{ 
de.Properties[PropertyName][0] = PropertyValue; 
} 
else 
{ 
de.Properties[PropertyName].Add(PropertyValue); 
} 
} 
} 

/// <summary> 
/// 生成随机密码 
/// </summary> 
/// <returns></returns> 
public string SetSecurePassword() 
{ 
//RandomPassword rp = new RandomPassword(); 
return RandomPassword.Generate(8,; 
} 

/// <summary> 
/// 设置用户新密码 
/// </summary> 
/// <param name="path"></param> 
public void SetPassword(string path) 
{ 
DirectoryEntry usr = new DirectoryEntry(); 
usr.Path = path; 
usr.AuthenticationType = AuthenticationTypes.Secure; 
object[] password = new object[] { SetSecurePassword() }; 
object ret = usr.Invoke("SetPassword", password); 
usr.CommitChanges(); 
usr.Close(); 
} 

/// <summary> 
/// 启用用户帐号 
/// </summary> 
/// <param name="de"></param> 
private static void EnableAccount(DirectoryEntry de) 
{ 
//UF_DONT_EXPIRE_PASSWD 0x10000 
int exp = (int)de.Properties["userAccountControl"].Value; 
de.Properties["userAccountControl"].Value = exp | 0x0001; 
de.CommitChanges(); 
//UF_ACCOUNTDISABLE 0x0002 
int val = (int)de.Properties["userAccountControl"].Value; 
de.Properties["userAccountControl"].Value = val & ~0x0002; 
de.CommitChanges(); 
} 

/// <summary> 
/// 添加用户到组 
/// </summary> 
/// <param name="de"></param> 
/// <param name="deUser"></param> 
/// <param name="GroupName"></param> 
public static void AddUserToGroup(DirectoryEntry de, DirectoryEntry deUser, string GroupName) 
{ 
DirectorySearcher deSearch = new DirectorySearcher(); 
deSearch.SearchRoot = de; 
deSearch.Filter = "(&(objectClass=group) (cn=" + GroupName + "))"; 
SearchResultCollection results = deSearch.FindAll(); 

bool isGroupMember = false; 

if (results.Count > 0) 
{ 
DirectoryEntry group = AdHerlp.GetDirectoryEntry(results[0].Path); 

object members = group.Invoke("Members", null); 
foreach (object member in (IEnumerable)members) 
{ 
DirectoryEntry x = new DirectoryEntry(member); 
if (x.Name != deUser.Name) 
{ 
isGroupMember = false; 
} 
else 
{ 
isGroupMember = true; 
break; 
} 
} 

if (!isGroupMember) 
{ 
group.Invoke("Add", new object[] { deUser.Path.ToString() }); 
} 
group.Close(); 
} 
return; 
} 

/// <summary> 
/// 创建一个新用户 
/// </summary> 
/// <param name="employeeID"></param> 
/// <param name="name"></param> 
/// <param name="login"></param> 
/// <param name="email"></param> 
/// <param name="group"></param> 
public void CreateNewUser(string employeeID, string name, string login, string email, string group) 
{ 
//Catalog catalog = new Catalog(); 
DirectoryEntry de =AdHerlp.GetDirectoryEntry(); 

/// 1. Create user account 
DirectoryEntries users = de.Children; 
DirectoryEntry newuser = users.Add("CN=" + login, "user"); 

/// 2. Set properties 
SetProperty(newuser, "employeeID", employeeID); 
SetProperty(newuser, "givenname", name); 
SetProperty(newuser, "SAMAccountName", login); 
SetProperty(newuser, "userPrincipalName", login); 
SetProperty(newuser, "mail", email); 
newuser.CommitChanges(); 

/// 3. Set password 
SetPassword(newuser.Path); 
newuser.CommitChanges(); 

/// 4. Enable account           
EnableAccount(newuser); 

/// 5. Add user account to groups 
AddUserToGroup(de, newuser, group); 

/// 6. Create a mailbox in Microsoft Exchange   
//GenerateMailBox(login); 

newuser.Close(); 
de.Close(); 
} 
/// <summary> 
/// 禁用一个帐号 
/// </summary> 
/// <param name="EmployeeID"></param> 
public void DisableAccount(string EmployeeID) 
{ 
DirectoryEntry de =AdHerlp.GetDirectoryEntry(); 
DirectorySearcher ds = new DirectorySearcher(de); 
ds.Filter = "(&(objectCategory=Person)(objectClass=user)(employeeID=" + EmployeeID + "))"; 
ds.SearchScope = SearchScope.Subtree; 
SearchResult results = ds.FindOne(); 

if (results != null) 
{ 
DirectoryEntry dey = AdHerlp.GetDirectoryEntry(results.Path); 
int val = (int)dey.Properties["userAccountControl"].Value; 
dey.Properties["userAccountControl"].Value = val | 0x0002; 
dey.Properties["msExchHideFromAddressLists"].Value = "TRUE"; 
dey.CommitChanges(); 
dey.Close(); 
} 

de.Close(); 
} 
/// <summary> 
/// 修改用户信息 
/// </summary> 
/// <param name="employeeID"></param> 
/// <param name="department"></param> 
/// <param name="title"></param> 
/// <param name="company"></param> 
public void ModifyUser(string employeeID, string department, string title, string company) 
{ 
DirectoryEntry de = AdHerlp.GetDirectoryEntry(); 
DirectorySearcher ds = new DirectorySearcher(de); 
ds.Filter = "(&(objectCategory=Person)(objectClass=user)(employeeID=" + employeeID + "))"; 
ds.SearchScope = SearchScope.Subtree; 
SearchResult results = ds.FindOne(); 

if (results != null) 
{ 
DirectoryEntry dey = AdHerlp.GetDirectoryEntry(results.Path); 
SetProperty(dey, "department", department); 
SetProperty(dey, "title", title); 
SetProperty(dey, "company", company); 
dey.CommitChanges(); 
dey.Close(); 
} 

de.Close(); 
} 

/// <summary> 
/// 检验Email格式是否正确 
/// </summary> 
/// <param name="mail"></param> 
/// <returns></returns> 
public bool IsEmail(string mail) 
{ 
Regex mailPattern = new Regex(@"\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"); 
return mailPattern.IsMatch(mail); 
} 
/// <summary> 
/// 搜索被修改过的用户 
/// </summary> 
/// <param name="fromdate"></param> 
/// <returns></returns> 
public DataTable GetModifiedUsers(DateTime fromdate) 
{ 
DataTable dt = new DataTable(); 
dt.Columns.Add("EmployeeID"); 
dt.Columns.Add("Name"); 
dt.Columns.Add("Email"); 

DirectoryEntry de = AdHerlp.GetDirectoryEntry(); 
DirectorySearcher ds = new DirectorySearcher(de); 

StringBuilder filter = new StringBuilder(); 
filter.Append("(&(objectCategory=Person)(objectClass=user)(whenChanged>="); 
filter.Append(ToADDateString(fromdate)); 
filter.Append("))"); 

ds.Filter = filter.ToString(); 
ds.SearchScope = SearchScope.Subtree; 
SearchResultCollection results = ds.FindAll(); 

foreach (SearchResult result in results) 
{ 
DataRow dr = dt.NewRow(); 
DirectoryEntry dey = AdHerlp.GetDirectoryEntry(result.Path); 
dr["EmployeeID"] = dey.Properties["employeeID"].Value; 
dr["Name"] = dey.Properties["givenname"].Value; 
dr["Email"] = dey.Properties["mail"].Value; 
dt.Rows.Add(dr); 
dey.Close(); 
} 

de.Close(); 
return dt; 
} 

/// <summary> 
/// 格式化AD的时间 
/// </summary> 
/// <param name="date"></param> 
/// <returns></returns> 
public string ToADDateString(DateTime date) 
{ 
string year = date.Year.ToString(); 
int month = date.Month; 
int day = date.Day; 

StringBuilder sb = new StringBuilder(); 
sb.Append(year); 
if (month < 10) 
{ 
sb.Append("0"); 
} 
sb.Append(month.ToString()); 
if (day < 10) 
{ 
sb.Append("0"); 
} 
sb.Append(day.ToString()); 
sb.Append("000000.0Z"); 
return sb.ToString(); 
} 
} 

校验： 

using System.DirectoryServices;    
//srvr = ldap server, e.g. LDAP://domain.com    
////usr = user name    
////pwd = user password    
//public bool IsAuthenticated(string srvr, string usr, string pwd)    {        bool authenticated = false;        try        {            DirectoryEntry entry = new DirectoryEntry(srvr, usr, pwd);            object nativeObject = entry.NativeObject;            authenticated = true;        }        catch (DirectoryServicesCOMException cex)        {            //not authenticated; reason why is in cex        }        catch (Exception ex)        {            //not authenticated due to some other exception [this is optional]        }        return authenticated;    }更多请看 http://www.codeproject.com/KB/system/everythingInAD.aspx

来源： <http://yaoyanzhu.iteye.com/blog/698475>
  
