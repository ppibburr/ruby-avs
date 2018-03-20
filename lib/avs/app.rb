$: << File.join(File.dirname(__FILE__), "..")

require 'json'

require 'avs/speaker'
require 'avs/speech_recognizer'
require 'avs/speech_synthesizer'

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
    end
  
    def token
      return @token if @token   
      
      payload = {"client_id": client_id, "client_secret": client_secret, "refresh_token": refresh_token, "grant_type": "refresh_token", }
      url = "https://api.amazon.com/auth/o2/token"

      cmd="curl -o - -X POST -H 'Content-Type: application/json' -d '#{payload.to_json}' #{url}"
      puts cmd if false
   
      JSON.parse(`#{cmd}`)['access_token']
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
        p d if true
      
        if AVS.const_defined?((namespace=d['namespace']).to_sym)
          if respond_to?(target=namespace.gsub(/([a-z])([A-Z])/) do |*o| "#{$1}_#{$2}" end.downcase.to_sym)
            if response=send(target).send(d['name'].gsub(/([a-z])([A-Z])/) do |*o| "#{$1}_#{$2}" end.downcase.to_sym, d, content)
              directive *response if response.is_a?(Array) and response[0].is_a?(Hash) and response[0]['messageBody']
            end
          else
            AVS.log "Unimplemented method: #{d['name']}"
          end
        else
          AVS.log "Unsupported Namespace: #{namespace}" 
        end
      end
    end
    
    def set_listener &b
      speech_recognizer.singleton_class.class_eval do
        define_method :_perform_listen, &b
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
  end
  
  class OnDeviceWake < AppV1
    Thread.abort_on_exception = true
    
    def set_listener &b
      super do
        until @wake; end
        b.call
        @wake = false
      end
    end
    
    def wake
      @wake = true
    end
  end
end
