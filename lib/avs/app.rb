$: << File.join(File.dirname(__FILE__), "..")

require 'json'

require 'avs/speaker'
require 'avs/speech_recognizer'
require 'avs/speech_synthesizer'
require 'avs/util/stt'

module AVS
  class AppV1
    attr_reader :client_id, :client_secret, :refresh_token, :speech_recognizer, :speaker, :speech_synthesizer
    def initialize client_id: nil, client_secret: nil, refresh_token: nil
      @client_id     = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
      
      @speech_recognizer  = AVS::SpeechRecognizer.new(token)
      @speech_synthesizer = AVS::SpeechSynthesizer.new
      @speaker            = AVS::Speaker.new            
    
      this = self
    
      set_mute do |mute|
        this.mute   if mute
        this.unmute if !mute
      end
    end
  
    def token
      return @token if @token   
      
      payload = {"client_id": client_id, "client_secret": client_secret, "refresh_token": refresh_token, "grant_type": "refresh_token", }
      url = "https://api.amazon.com/auth/o2/token"

      res = AVS::Util.shell "curl -o - -X POST -H 'Content-Type: application/json' -d '#{payload.to_json}' #{url}", json: true
      
      res['access_token'] if res
    end
    
    def directive obj, content
      if true
        File.open("./log.json", "w") do |f| f.puts obj.to_json end
        
        i=0
        content.each_pair do |k,v|
          File.open("./content_#{i+=1}.part", "w") do |f|
            f.puts v
          end
        end
      end
    
      ((obj['messageBody'] ||= {})['directives'] ||= []).each do |d|
        Util.log :DIRECTIVE, d.to_json, true
      
        if AVS.const_defined?((namespace=d['namespace']).to_sym)
          if respond_to?(target=namespace.gsub(/([a-z])([A-Z])/) do |*o| "#{$1}_#{$2}" end.downcase.to_sym)
            if response=send(target).send(d['name'].gsub(/([a-z])([A-Z])/) do |*o| "#{$1}_#{$2}" end.downcase.to_sym, d, content)
              directive *response if response.is_a?(Array) and response[0].is_a?(Hash) and response[0]['messageBody']
            end
          else
            raise "Unimplemented method: #{d['name']}"
          end
        else
          raise "Unsupported Namespace: #{namespace}" 
        end
      end
    end
    
    def set_listener &b
      this = self
      speech_recognizer.singleton_class.class_eval do
        define_method :_perform_listen do |*o|
          this.mute
          r=b.call *o
          this.unmute
          r
        end
      end
    end
    
    def set_mute &b
      speaker.singleton_class.class_eval do
        define_method :_mute, &b
      end
    end
    
    def set_speak &b
      speech_synthesizer.singleton_class.class_eval do
        define_method :_perform_speak, &b
      end    
    end
    
    def run
      while true
        directive *speech_recognizer.listen
      end
    end
    
    def mute;   end
    
    def unmute; end    
    
    def alert;  end
    def alert1; end
  end
  
  class OnDeviceWake < AppV1
    Thread.abort_on_exception = true
    
    def wake
      directive *speech_recognizer.listen
    end
    
    def run
      while true
        text = STDIN.gets
        tts(text)
      end
    end
  
    def wake input: false
      unless input
        alert
        
        input = speech_recognizer.send :_perform_listen
        
        alert1
      end
      
      unless custom_voice_service
        directive *speech_recognizer.recognize(input)
      end
    end

    # Override to implement tts. super(audio_file: "/path/to/file")
    def tts text=nil, audio_file: nil
      raise "NotImplemented" if text
      
      wake input: audio_file if audio_file
    end
    
    def custom_voice_service; end
    
    def stt path: "./input.wav", io: nil
      @stt ||= Util::STT.new
      
      @stt.recognize path: path, io: io 
    end
  end
end
