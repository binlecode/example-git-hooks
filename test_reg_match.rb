

$regex = /^(ref|feat|fix|chore): (\d+)/

msg = 'ref: abc 123 - this is a commit msg'

caught = $regex.match(msg)

unless caught
    puts "message format is not correct"
    exit(1)
end

puts "found match: #{caught}"
tkt_nbr = caught[-1]
puts tkt_nbr


