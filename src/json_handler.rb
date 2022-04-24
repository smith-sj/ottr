require 'json'

module JSONHandler
  def load_json(file)
    File.read(file)
  end

  def write_json(file, data)
    File.write(file, JSON.dump(data))
  end

  def json_array(file)
    JSON.parse!(load_json(file))
  end
end
