JPEG World File Format (*.jgw)
The JPEG World File stores the georeferencing information for *.jpg raster maps. The file name of *.jgw files has to be identical to the name of the corresponding map stored within the same directory.
The resulting file contains the transformation factors A to F defining the registering of the image in accordance with the equation below:
x' = A x + B y + C
y' = D x + E y + F
with 
x,y = image coordinates
x',y'= real world coordinates
A = x scale
B,D = rotation terms
C,F = translation terms
E = y scale (negative)
Example for a .jgw file:
4.23214625853148 - A
0.00000000000000 - D
0.00000000000000 - B
-4.23214625853148 - E
3404018.70881921 - C
5819863.55539414 - F

来源： <http://www.feflow.info/html/help/HTMLDocuments/reference/fileformats/rastermaps/geographicreference/jgw.htm>
 
