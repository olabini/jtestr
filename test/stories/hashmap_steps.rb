import java.util.HashMap

$maps = { }

steps_for(:hashmap) do
  Given('my $map_name contains "$key" with value "$value"') do |map_name, key, value|
    $maps[map_name] ||= HashMap.new
    $maps[map_name][key] = value
  end
  Given('my $map_name is empty') do |map_name|
    $maps[map_name] ||= HashMap.new
    $maps[map_name].clear
  end
  When('I transfer value with key "$key" from my $from_map to my $to_map') do |key, from_map, to_map|
    $maps[to_map][key] = $maps[from_map][key]
    $maps[from_map].remove(key)
  end
  Then('my $map_name should contain "$key" with value "$value"') do |map_name, key, value|
    $maps[map_name][key].should == value
  end
  Then('my $map_name should be empty') do |map_name|
    $maps[map_name].should be_empty
  end
end

with_steps_for(:hashmap) do 
  run 'test/stories/hashmap.story'
end
