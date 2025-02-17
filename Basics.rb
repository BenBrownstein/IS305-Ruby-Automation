num = 3 ** 2
string = "Test Words"
puts string
puts string.length * num
puts string.upcase
puts string.downcase

if num > 5
    puts "Big Number"
else
    puts "Small Number"
end

i = 0
while i < 5 do
    puts i
    i += 1
end

puts "counter is #{i}"

until i < 0 do 
    puts i
    i = i -2
end

puts "counter is #{i}"

def test (message="test")
    return "This message says #{message}."
end
puts test
puts test(123)