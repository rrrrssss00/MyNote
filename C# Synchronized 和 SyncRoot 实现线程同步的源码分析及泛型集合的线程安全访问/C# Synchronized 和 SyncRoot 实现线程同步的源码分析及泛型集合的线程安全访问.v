Synchronized vs SyncRoot 我们知道，在.net的一些集合类型中，譬如Hashtable和ArrayList，都有Synchronized静态方法和SyncRoot实例方法，他们之间有联系吗？我怎么才能用好他们呢？
我们以Hashtable为例，看看他们的基本用法：
Hashtable ht = Hashtable.Synchronized(new Hashtable());
lock (ht.SyncRoot)
{
//一些操作
}
 
Synchronized表示返回一个线程安全的Hashtable，什么样的 hashtable才是一个线程安全的呢？下边我们就从.NET的源码开始理解。
public static Hashtable Synchronized(Hashtable table)
{
if (table == null)
{
throw new ArgumentNullException("table");
}
return new SyncHashtable(table);
}
从 源码不难看出，Synchronized方法返回的其实是一个SynchHashtable类型的实例。在前边我们说过，Synchronized表示返 回一个线程安全的Hashtable，从这个解释不难看出，SynchHashtable应该是继承自Hashtable。下边我们验证一下。看看 SynchHashtable类型的源码： Code
[Serializable]
private class SyncHashtable : Hashtable
{
// Fields
protected Hashtable _table;
// Methods
internal SyncHashtable(Hashtable table) : base(false)
{
this._table = table;
}
internal SyncHashtable(SerializationInfo info, StreamingContext context) : base(info, context)
{
this._table = (Hashtable) info.GetValue("ParentTable", typeof(Hashtable));
if (this._table == null)
{
throw new SerializationException(Environment.GetResourceString("Serialization_InsufficientState"));
}
}
public override void Add(object key, object value)
{
lock (this._table.SyncRoot)
{
this._table.Add(key, value);
}
}
public override void Clear()
{
lock (this._table.SyncRoot)
{
this._table.Clear();
}
}
public override object Clone()
{
lock (this._table.SyncRoot)
{
return Hashtable.Synchronized((Hashtable) this._table.Clone());
}
}
public override bool Contains(object key)
{
return this._table.Contains(key);
}
public override bool ContainsKey(object key)
{
return this._table.ContainsKey(key);
}
public override bool ContainsValue(object key)
{
lock (this._table.SyncRoot)
{
return this._table.ContainsValue(key);
}
}
public override void CopyTo(Array array, int arrayIndex)
{
lock (this._table.SyncRoot)
{
this._table.CopyTo(array, arrayIndex);
}
}
public override IDictionaryEnumerator GetEnumerator()
{
return this._table.GetEnumerator();
}
public override void GetObjectData(SerializationInfo info, StreamingContext context)
{
if (info == null)
{
throw new ArgumentNullException("info");
}
info.AddValue("ParentTable", this._table, typeof(Hashtable));
}
public override void OnDeserialization(object sender)
{
}
public override void Remove(object key)
{
lock (this._table.SyncRoot)
{
this._table.Remove(key);
}
}
internal override KeyValuePairs[] ToKeyValuePairsArray()
{
return this._table.ToKeyValuePairsArray();
}
// Properties
public override int Count
{
get
{
return this._table.Count;
}
}
public override bool IsFixedSize
{
get
{
return this._table.IsFixedSize;
}
}
public override bool IsReadOnly
{
get
{
return this._table.IsReadOnly;
}
}
public override bool IsSynchronized
{
get
{
return true;
}
}
public override object this[object key]
{
get
{
return this._table[key];
}
set
{
lock (this._table.SyncRoot)
{
this._table[key] = value;
}
}
}
public override ICollection Keys
{
get
{
lock (this._table.SyncRoot)
{
return this._table.Keys;
}
}
}
public override object SyncRoot
{
get
{
return this._table.SyncRoot;
}
}
public override ICollection Values
{
get
{
lock (this._table.SyncRoot)
{
return this._table.Values;
}
}
}
}

Collapse Methods
 
呵呵，果然不出我们所料，SyncHashtable果然继承自Hashtable，SyncHashtable之所有能实现线程的安全操作，就是 因为在他们的一些方法中，就加了lock，我们知道，哪一个线程执行了lock操作，在他还没有释放lock之前，其他线程都要处于堵塞状态。 SyncHashtable就是通过这种方法，来实现所谓的线程安全。
现在我们理解了Synchronized的含义和用法，那接下来我们看看他和SyncRoot之间的关系。
SyncRoot表示获取可用于同步 Hashtable 访问的对象，老实说，这个解释不好理解，要想真正理解他的用法，我们还得从源码开始： public virtual object SyncRoot
{
get
{
if (this._syncRoot == null)
{
Interlocked.CompareExchange(ref this._syncRoot, new object(), null);
}
return this._syncRoot;
}
}

如果您清楚Interlocked的用法，这段代码没什么难理解的了（不清楚的朋友找GOOGLE吧），Interlocked为多个线程 共享的变量提供原子操作。原子操作就是单线程操作。在一个Hashtable实例中，不论我们在代码的任何位置调用，返回的都是同一个object类型的 对象。我们在开始写的 lock(ht.SyncRoot)和下边的操作作用是一样的.
static object obj = new object();
lock(obj)
{
// 一些操作
}
他们之间不同的是，我们声明的static object类型对象是类型级别的，而SyncRoot是对象级别的。
通过上面的分析，我们都应该能理解Synchronized 和 SyncRoot用法，他们之间的关系就是：
Hashtable 通过Synchronized方法，生成一个SynchHashtable类型的对象，在这个对象的一个方法中，通过lock (this._table.SyncRoot)这样的代码来实现线程安全的操作，其中this._table.SyncRoot返回的就是一个 object类型的对象，在一个SynchHashtable对象实例中，不管我们调用多少次，他是唯一的。
 
 
另外，针对泛型集合的线程安全访问，由于泛型集合中没有直接公布SyncRoot属性，所以猛一看好似无从下手。
但是查看集合泛型集合的源代码后就可发现他们实际上都提供了SyncRoot属性。
以下以Queue<T>集合为例。
 
bool ICollection.IsSynchronized
{
    get
    {
        return false;
    }
}
 
object ICollection.SyncRoot
{
    get
    {
        if (this._syncRoot == null)
        {
            Interlocked.CompareExchange(ref this._syncRoot, new object(), null);
        }
        return this._syncRoot;
    }
}
 
从以上源代码可以看出，这两个方法都被实现为了private，不过使用ICollection接口还是可以访问的。
lock (((ICollection)_queue).SyncRoot)        
{            
 int item = _queue.Dequeue();        
}

来源： <http://blog.csdn.net/zztfj/article/details/5640889>
 
