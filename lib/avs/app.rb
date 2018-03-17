$: << File.join(File.dirname(__FILE__), "..")

require 'json'

require 'avs/speaker'
require 'avs/speech_recognizer'
require 'avs/speech_synthesizer'

module AVS
  class AppV1
    attr_reader :client_id, :client_secret, :refresh_token, :speech_recognizer
    def initialize client_id: nil, client_secret: nil, refresh_token: nil
      @client_id     = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
      
      @speech_recognizer = AVS::SpeechRecognizer.new(token)
    end
  
    def token
      return @token if @token   
      
      payload = {"client_id": client_id, "client_secret": client_secret, "refresh_token": refresh_token, "grant_type": "refresh_token", }
      url = "https://api.amazon.com/auth/o2/token"

      cmd="curl -o - -X POST -H 'Content-Type: application/json' -d '#{payload.to_json}' #{url}"
      puts cmd if false
   
      JSON.parse(`#{cmd}`)['access_token']
    end
    
    def directive obj, data
      ((obj['messageBody'] ||= {})['directives'] ||= []).each do |d|
        p d
      end
      speak data: data
    end
    
    def listen voice_file = './input.wav'
      speech_recognizer.recognize(voice_file)     
    end
    
    def speak file: nil, data: nil
      SpeechSynthesizer.speak(data ? data : open(file).read)
    end
  end
  
  class OnDeviceWake < AppV1
    Thread.abort_on_exception = true
    def run
      Thread.new do
        loop do
          until @wake; end
          
          @wake = false
          
          directive *listen
        end
      end
    end
    
    def wake;
      @wake = true
    end
  end
end
