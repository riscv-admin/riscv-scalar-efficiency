require 'yaml'

file = File.realpath(ARGV[0])

lines = File.readlines(file)

keys = lines[0].split(',')

objs = []

keymap = {
  'Instruction' => 'mnemonic',
  'Enc Size' => 'enc_size',
  'Base' => 'base',
  'Processor Class' => 'class',
  'Donated by' => 'donator',
  'Known impl?' => 'implemented',
  'Description' => 'description',
  'free bits' => 'free_bits',
  'Notes' => 'notes'
}

lines[1..-1].each do |line|
  values = line.split(',')
  obj = {}
  keys.each_index do |idx|
    break if idx > 0 && (keys[idx-1] == "Notes")
    if keys[idx] == "Enc Size" || keys[idx] == 'free bits'
      obj[keymap[keys[idx]]] = values[idx].to_i
    elsif keys[idx] == 'Known impl?'
      obj['implemented'] = values[idx] == 'No' ? false : true
    elsif keys[idx] == "Category"
      obj['categories'] = []
      values[idx].split(' ').each do |cat|
        obj['categories'] << cat[1..-1]
      end
    elsif keys[idx] == "# srcs"
      obj['srcs'] = values[idx].to_i
    elsif keys[idx] == "# dsts"
      obj['dsts'] = values[idx].to_i
    elsif keys[idx] == "% 32-bit SROS" || keys[idx] == "% of remaining 32-bit SROS" || keys[idx] == "R-type Equiv"
      # skip
    else
      if keymap.key?(keys[idx])
        obj[keymap[keys[idx]]] = values[idx]
      else
        obj[keys[idx]] = values[idx]
      end
    end
  end
  objs << obj if !values[0].nil? && !values[0].empty?
end


puts "# yaml-language-server: $schema=inst_schema.json"
puts YAML.dump(objs)