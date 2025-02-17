#PDF Multitool Project File
require 'combine_pdf'


#Functions
=begin
split(file, page_number)
  splits the pdf file at the page number
  return newfile1, newfile2
=end

def join(file1, file2, filename = "combined.pdf")
  pdf = CombinePDF.new
  pdf << CombinePDF.load(file1) # Load and append the first PDF
  pdf << CombinePDF.load(file2) # Load and append the second PDF
  pdf.save(filename) # Save the merged PDF
  puts "PDFs merged successfully into #{filename}!"
end 

=begin
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

join("D:/IS 305 Ruby/python toolbox certificate.pdf", "D:/IS 305 Ruby/intro to importing data cert.pdf")