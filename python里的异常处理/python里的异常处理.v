标准格式：
try:
    print('try...')
    r = 10 / int('a')
    print('result:', r)
except ValueError as e:
    print('ValueError:', e)
except ZeroDivisionError as e:
    print('ZeroDivisionError:', e)
except Exception as ex:
    if(len(ex.args)>0):	
    	print('通用异常：'+ex.args[0].message)
else:
    #没有异常的时候调用
finally:
    print('finally...')

抛出异常使用：
	raise 
