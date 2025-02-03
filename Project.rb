#PDF Multitool Project File

#Functions
=begin
split(file, page_number)
  splits the pdf file at the page number
  return newfile1, newfile2

join(file1, file2)
  adds file2 to the end of file1
  return newfile

chunk (file, pagenumber1, pagenumber2)
  makes a series of pages a seperate file in  the range of pagenumber1 to pagenumber2
  return newfile

convert_To_Plain_Text(file)
  makes a newfile with the text of the pdf file
  return newfile

make_Form_Fillable(file, pagenumber, coordx, coordy, size)
  makes a form fillable box starting at coordx, coordy on pagenumber of file and is size large
  return newfile
=end

