-- This will run indefinitely, consuming client resources
while true do
  local x = 0
  for i = 1, 10000 do
    x = x + math.sqrt(i)
  end
end
