#PDF Multitool Project File
#Required Gems for the project to function
require "combine_pdf"
require "hexapdf"
require "pdf-reader"
require "tk"
require "listen"

#Functions
# Opens up the file dialogue/selector and returns the selected file as a string
def file_Selection()
  # Opens the file selector
  filename = Tk.getOpenFile
  # If the file is a .pdf file then it will return the filename (file path) and let the user know it is a valid file
  if filename.end_with?(".pdf")
    puts "This is a valid file"
    return filename
  else
    # If the file is not a .pdf file then it will raise an error
    raise ArgumentError, "This is not a .pdf file"
  end
end


# Combines the contents of two PDF files with file1 being the first part
# Takes 2 files and has the option to change the file name
def join_pdf(file1, file2, filename: "combined.pdf")
  # Creates a new PDF file using CombinePDF
  pdf = CombinePDF.new
  # Loads the first file onto the new empty file
  pdf << CombinePDF.load(file1)
  # Adds the second file onto the back of the first file
  pdf << CombinePDF.load(file2)
  # Saves the file as the filename
  pdf.save(filename)
  # Message letting use know it worked in console
  puts "PDFs merged successfully into #{filename}"
end

# Seperates the PDF file on pagenumber
# Takes a file, a pagenumber to split it on, and has the option to rename the front and back files of the split
def split_pdf(file, page_number, filename1: "split_front.pdf", filename2: "split_back.pdf")
  # Loads the file using CombinePDF
  pdf = CombinePDF.load(file)
  # Creates 2 new PDF files using CombinePDF to store the parts
  split_front_pdf = CombinePDF.new
  split_back_pdf = CombinePDF.new
  # Add the pages from 0 to page_number to the front half part of the split
  (0...page_number).each do |i|
    split_front_pdf << pdf.pages[i] if i <= pdf.pages.count
  end
  # Saves the front half file as filename1
  split_front_pdf.save(filename1)
  # Goes from page_number to the end of the file and adding those pages to the back half file
  (page_number...pdf.pages.count).each do |i|
    split_back_pdf << pdf.pages[i] if i <= pdf.pages.count
  end
  # Saves the back half file as filename2
  split_back_pdf.save(filename2)
  # Message letting use know it worked in console
  puts "PDF split successfully: #{filename1} and #{filename2}"
end


# Takes a group of pages from a pdf file
# Takes a file and a two page number range it has an option to rename the file 
def chunk_pdf(file, page_number1, page_number2, filename: "chunk.pdf")
  # Loads the file using CombinePDF
  pdf = CombinePDF.load(file)
    # Creates a new PDF file using CombinePDF to store the chunk
  chunk_pdf = CombinePDF.new
  # If the page numbers are the same only take the one page and add it to the new file
  if page_number1 == page_number2
    chunk_pdf << pdf.pages[page_number1] if page_number1 < pdf.pages.count
  # Goes from page_number1 to page_number2 and adds all of those pages to the chunk_pdf file
  else
    (page_number1...page_number2).each do |i|
      chunk_pdf << pdf.pages[i] if i < pdf.pages.count
    end
  end
  # Saves the file as filename
  chunk_pdf.save(filename)
  puts "PDF chunked successfully: #{filename}"
end

# Takes a PDF file and returns the text contents of it as a txt file
# Takes a file and can optionally take a filename
def convert_To_Plain_Text(file, filename: "text_from_pdf.txt")
  # Creates a new pdf reader for file
  reader = PDF::Reader.new(file)
  # Empty string to hold the text
  text = ""
  # For each page of the file add the text of that page to text
  reader.pages.each do |page|
    text += page.text
  end
  # Creates a new file with filename and add the text variable to that new file
  File.open(filename, "w") do |file|
    file.write(text)
  end
  puts "PDF converted to a txt file #{filename} successfully"
end

# Makes a fillable box on a PDF file
# Takes a file, x coordinate, y coordinate, width of the box, and the height of the box
# The optionals are page number, fieldname for later usage with Hexapdf and so multiple fields can be added to the same file, filename, and if it is a single line or multi line text box
def make_Form_Fillable(file, coordx, coordy, width, height, page_number: 1, fieldname: "text_field", filename: "form-fillable.pdf", single: true)
  # Opens file using HexaPDF
  doc = HexaPDF::Document.open(file)
  # Creates an acro_form which represents PDF;s interactive form dictionary
  form = doc.acro_form(create: true)
  # If single is true which it is by default then it will create a regular text field with fieldname
  if single == true
    field = form.create_text_field(fieldname)
  # If single is not true then it will create a multiline text field with fieldname
  else
    field = form.create_multiline_text_field(fieldname)
  end
  # Goes to the page but it is 0 indexed so -1 is done so the user can use the actual page number
  page = doc.pages[page_number - 1]
  # Creates the text field/box on page at the coordinates, width, and height given
  widget = field.create_widget(page, Rect: [coordx, coordy, coordx + width, coordy + height])
  # This adds the created widget which has the text box to the page 
  page[:Annots] = [] unless page[:Annots]
  page[:Annots] << widget
  # Saves the file as filename
  doc.write(filename)
  puts "Created a fillable text box for #{filename}"
end

# The actual automation of the project
# Takes a file and runs convert to plain text on it returning it in the Output folder as Plain_Text_Filename.txt
def process_New_File_To_Text(file)
  # Where the Output folder is located
  output_dir = "D:/IS 305 Ruby/Output"
  # The new file name of the output
  filename = File.join(output_dir, "Plain_Text_" + File.basename(file) + ".txt")
  # Lets the user know that it detects a file
  puts "New file detected: #{file}"
  # Runs convert to plain text on file and uses filename as the filename
  # Because filename has file path info it will be created in the targeted directory with the filename
  convert_To_Plain_Text(file, filename: filename)
end

# When
def process_New_Files_To_Combine_All(folder_path)
  # The location of the combined.pdf that will be added on to by new files entering the folder_path
  file_path = "D:/IS 305 Ruby/Output/combined.pdf"
  # This gets all .pdf files in the targeted folder
  pdf_files = Dir.glob(File.join(folder_path, "*.pdf"))
  # If there is not 2 pdf files in the folder_path return a message stating such and the number of pdf files in the folder
  if pdf_files.size < 2
    puts "Waiting for at least 2 PDFs... (Found: #{pdf_files.size})"
    return
  end
  # If combined.pdf already exists in Output then join combined and the newest pdf file
  # filename as file_path is so the joined file goes to the Output folder
  if File.exist?(file_path)
    join_pdf(file_path, pdf_files.last, filename: file_path)
  # If combined.pdf does not exist in Output join the newest pdf files
  else
    join_pdf(pdf_files[0], pdf_files[1], filename: file_path)  
  end
end

# File path for directory being watched
watch_dir_plain_text = "D:/IS 305 Ruby/Make Plain Text"
# This is the first listener which watches the Make Plain text folder and if a .pdf file is modified or added does to the folder then it performs process_New_File_To_Text on the added file
listener1 = Listen.to(watch_dir_plain_text, only: /\.pdf$/) do |modified, added|
  added.each do |file|
    process_New_File_To_Text(file) if File.file?(file)  # Check if the added item is a file
  end
end


# File path for directory being watched
watch_dir_combine_all = "D:/IS 305 Ruby/Combine All"
# This is the second listener which watches the Combine All folder and .pdf file is modified or added does to the folder then it performs process_New_Files_To_Combine_All on the added file
listener2 = Listen.to(watch_dir_combine_all, only: /\.pdf$/) do |modified, added|
  # It will only do the add if there is at least 2 .pdf files in the folder
  if Dir.glob(File.join(watch_dir_combine_all, "*.pdf")).size >= 2
    process_New_Files_To_Combine_All(watch_dir_combine_all)
  else
    # Given a message letting the user know that it needs at least 2 PDF files
    puts "Waiting for at least 2 .PDF files"
  end
end

# Lets user know that the listeners are running 
puts "Watching folder for new PDF files..."
# Starts the listeners for the events to occur
# listener1.start
# listener2.start
# sleep


# file1 = file_Selection()
# file2 = file_Selection()
# join_pdf(file1, file2)

# split_pdf("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 3)

# chunk_pdf("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 3, 5)
# chunk_pdf("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf", 2, 2, filename: "singlepagechunk.pdf")

# #Creates a textbox underneath the date of the header
# make_Form_Fillable(file1, 55, 710, 200, 20, page_number: 1)
make_Form_Fillable("D:/IS 305 Ruby/form-fillable.pdf", 415, 550, 160, 40, page_number: 1,fieldname: "second_field", filename: "multiline.pdf", single: false)

# convert_To_Plain_Text("D:/IS 305 Ruby/Ben Brownstein IS305 Project Report.pdf")
