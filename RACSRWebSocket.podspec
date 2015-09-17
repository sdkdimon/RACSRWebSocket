Pod::Spec.new do |s|
  s.name             = "RACSRWebSocket"
  s.version          = "1.1.2"
  s.summary          = "Reactive SocketRocket"
  s.homepage         = "https://github.com/sdkdimon/RACSRWebSocket"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Dmitry Lizin" => "sdkdimon@gmail.com" }
  s.source           = { :git => "https://github.com/sdkdimon/RACSRWebSocket.git", :tag => s.version }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.module_name = 'RACSRWebSocket'
  s.source_files = 'RACSRWebSocket/*.{h,m}'
  s.dependency 'ReactiveCocoa', '2.5'
  s.dependency 'SocketRocket', '0.4'
end



