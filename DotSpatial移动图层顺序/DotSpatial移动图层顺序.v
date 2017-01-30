                        //打开SHp文件，并添加到Map控件中
                        string tmpShp = shpPath;
                        FeatureSet tmpSet = DataManager.DefaultDataManager.OpenFile(tmpShp) as FeatureSet;
                        tmpSet.Projection = map1.Projection;
                        IMapLayer tmpLyr = map1.Layers.Add(tmpSet) as IMapLayer;
                        //将图层添加到网格图层上方，测量图层下方
                        tmpLyr.LockDispose();
                        map1.Layers.Remove(tmpLyr);
                        map1.Layers.Insert(3, tmpLyr);
                        tmpLyr.UnlockDispose();

若需要改变多个，则同理，多处理几次即可
