require 'avs'

class SampleApp < AVS::OnDeviceWake
  attr_accessor :resource_path
  def initialize *o
    @resource_path = File.join(File.dirname(__FILE__), "..", "..", "resources")
    
    super
    
    app = self
    
    set_listener do |time=5|
      app.play app.resource('alert.wav')
      
      app.record f='./input.wav', time
      
      Thread.new do
        app.play app.resource('alert.wav')
      end
      
      next f
    end
    
    set_speak do |data|
      IO.popen('bash -c "mpg321 -"', 'r+') do |io|
        io.puts data
      end    
    end
  end
  
  def record out, time=5
    if (rec = `which rec`.strip) != ''
      `rec -d -c 1 -r 16000 -e signed -b 16 #{out} trim 0 #{time}`
    elsif  (rec = `which arecord`.strip) != ''
      `#{rec} -r 16000 -f S16_LE -d #{time} #{out}`
    end  
  end
  
  def play file
    if file =~ /\.mp3$/
      `mpg321 #{file}`
    
      return
    end
    
    if ((play=`which play`) != '') or ((play=`which aplay`) != '')
      `#{play.strip} #{file}`
    else
      puts "no player found"
    end  
  end
  
  def run
    while true
      gets
      wake
    end
  end

  def resource file
    File.expand_path(File.join(@resource_path, file))
  end
end
