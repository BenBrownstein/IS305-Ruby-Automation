#PDF Multitool Project File
require "combine_pdf"
require "hexapdf"
require "pdf-reader"
require "tk"
require "listen"

#Functions
def split(file, page_number, filename1: "split_front.pdf", filename2: "split_back.pdf")
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

def join_pdf(file1, file2, filename: "combined.pdf")
  pdf = CombinePDF.new
  pdf << CombinePDF.load(file1)
  pdf << CombinePDF.load(file2) # Load and append the second PDF
  pdf.save(filename) # Save the merged PDF
  puts "PDFs merged successfully into #{filename}!"
end

def join_pdf_auto(file1, file2, filename: "D:/IS 305 Ruby/Output/combined.pdf")
  pdf = CombinePDF.new
  pdf << CombinePDF.load(file1)
  pdf << CombinePDF.load(file2) # Load and append the second PDF
  pdf.save(filename) # Save the merged PDF
  puts "PDFs merged successfully into #{filename}!"
end

def chunk(file, page_number1, page_number2, filename: "chunk.pdf")
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

def make_Form_Fillable(file, coordx, coordy, width, height, page_number: 1, fieldname: "text_field", filename: "form-fillable.pdf", single: true)
  doc = HexaPDF::Document.open(file)
  form = doc.acro_form(create: true)
  if single == true
    field = form.create_text_field(fieldname)
  else
    field = form.create_multiline_text_field(fieldname)
  end
  page = doc.pages[page_number - 1]
  widget = field.create_widget(page, Rect: [coordx, coordy, coordx + width, coordy + height])
  page[:Annots] = [] unless page[:Annots]
  page[:Annots] << widget
  doc.write(filename)
end

def file_selection()
  filename = Tk.getOpenFile
  if filename.end_with?(".pdf")
    puts "This is a valid file"
    return filename
  else
    raise ArgumentError, "This is not a .pdf file"
  end
end

def convert_To_Plain_Text(file, filename: "text_from_pdf.txt")
  reader = PDF::Reader.new(file)
  text = ""
  reader.pages.each do |page|
    text += page.text
  end
  
  File.open(filename, "w") do |file|
    file.write(text)
  end
end

def process_new_file_to_text(file)
  output_dir = "D:/IS 305 Ruby/Output"
  filename = File.join(output_dir, "Plain_Text_" + File.basename(file) + ".txt")
  puts "New file detected: #{file}"
  convert_To_Plain_Text(file, filename: filename)
end

def process_new_file_to_combine_all(folder_path)
  file_path = "D:/IS 305 Ruby/Output/combined.pdf"
  pdf_files = Dir.glob(File.join(folder_path, "*.pdf"))
  if pdf_files.size < 2
    puts "Waiting for at least 2 PDFs... (Found: #{pdf_files.size})"
    return
  end
  if File.exist?(file_path)
    join_pdf_auto(file_path, pdf_files.first)
  else
    join_pdf_auto(pdf_files[0], pdf_files[1])  
  end

end

watch_dir_plain_text = "D:/IS 305 Ruby/Make Plain Text"
listener1 = Listen.to(watch_dir_plain_text, only: /\.pdf$/) do |modified, added, removed|
  added.each do |file|
    process_new_file_to_text(file) if File.file?(file)  # Check if the added item is a file
  end
end

watch_dir_combine_all = "D:/IS 305 Ruby/Combine All"
listener2 = Listen.to(watch_dir_combine_all, only: /\.pdf$/) do |modified, added, removed|
  if Dir.glob(File.join(watch_dir_combine_all, "*.pdf")).size >= 2
    process_new_file_to_combine_all(watch_dir_combine_all)
  else
    puts "Waiting for at least 2 PDFs..."
  end
end

puts "Watching folder for new PDF files..."
listener1.start
listener2.start
sleep


# file1 = file_selection()
# file2 = file_selection()
# join_pdf(file1, file2)

# split("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 3)

# chunk("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 3, 5)
# chunk("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 2, 2, filename: "singlepagechunk.pdf")

# #Creates a textbox underneath the date of the header
# make_Form_Fillable("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 70, 615, 200, 20, page_number: 1)
# make_Form_Fillable("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 70, 615, 200, 20, page_number: 1, filename: "multiline.pdf", single: false)

# convert_To_Plain_Text("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf")
