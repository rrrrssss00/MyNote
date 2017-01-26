  private void button11_Click(object sender, EventArgs e)
        {
            //test insert binary
            MongoDatabase db = server.GetDatabase("aa");
            MongoCollection col= db.GetCollection("binarytest");
            BsonDocument doc = new BsonDocument();
            byte[] binary = GetBlob(Application.StartupPath + "\\test.gif");
            doc.Add("name", "testGif");
            BsonValue val = BsonValue.Create(binary);
            doc.Add("gif", val);
            col.Insert(doc);
        }
        private void button12_Click(object sender, EventArgs e)
        {
            //test save binary
            MongoDatabase db = server.GetDatabase("aa");
            MongoCollection col = db.GetCollection("binarytest");
            var cur = col.FindAllAs<BsonDocument>();
            var lst = cur.ToArray();
            var doc = lst.ElementAt(0);
            WriteBlob(Application.StartupPath+"\\test2.gif",doc["gif"].AsByteArray);
        }
        private static byte[] GetBlob(string sPath)
        {
            FileStream fs = new FileStream(sPath, FileMode.Open, FileAccess.Read);
            BinaryReader br = new BinaryReader(fs);
            byte[] blob = br.ReadBytes((int)fs.Length);
            br.Close();
            fs.Close();
            return blob;
        }
        private static void WriteBlob(string sPath, byte[] blob)
        {
            FileStream fs = new FileStream(sPath, FileMode.Create, FileAccess.Write);
            fs.Write(blob, 0, blob.Length);
            fs.Close();
        }

