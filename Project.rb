#PDF Multitool Project File
require 'combine_pdf'


#Functions
def split(file, page_number, filename1="split_front.pdf", filename2="split_back.pdf")
  pdf = CombinePDF.load(file)
  split_front_pdf = CombinePDF.new
  split_back_pdf = CombinePDF.new
  (0...page_number).each do |i|
    split_front_pdf << pdf.pages[i] if i <= pdf.pages.count
  end
  split_front_pdf.save(filename1)
  (page_number...pdf.pages.count).each do |i|
    split_back_pdf << pdf.pages[i] if i <= pdf.pages.count
  end
  split_back_pdf.save(filename2)
  puts "PDF split successfully: #{filename1} and #{filename2}!"
end

def join(file1, file2, filename = "combined.pdf")
  pdf = CombinePDF.new
  pdf << CombinePDF.load(file1) # Load and append the first PDF
  pdf << CombinePDF.load(file2) # Load and append the second PDF
  pdf.save(filename) # Save the merged PDF
  puts "PDFs merged successfully into #{filename}!"
end 

def chunk (file, page_number1, page_number2, filename="chunk.pdf")
  pdf = CombinePDF.load(file)
  chunk_pdf = CombinePDF.new
  if page_number1 == page_number2
    chunk_pdf << pdf.pages[page_number1] if page_number1 < pdf.pages.count
  else
    (page_number1...page_number2).each do |i|
      chunk_pdf << pdf.pages[i] if i < pdf.pages.count
    end
  end
  chunk_pdf.save(filename)
end


=begin
convert_To_Plain_Text(file)
  makes a newfile with the text of the pdf file
  return newfile

make_Form_Fillable(file, pagenumber, coordx, coordy, size)
  makes a form fillable box starting at coordx, coordy on pagenumber of file and is size large
  return newfile
=end

join("D:/IS 305 Ruby/python toolbox certificate.pdf", "D:/IS 305 Ruby/intro to importing data cert.pdf")
split("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 3)
chunk("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 3, 5)
chunk("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 2, 2, "singlepagechunk.pdf")