Pod::Spec.new do |s|
  s.name = 'FKGuardUIView'
	s.summary = 'This a simply tool to help you waring that all non-mainthread UI opreation on the run-time.'
	s.version = '0.0.1'
	s.license = { :type => 'MIT', :file => 'LICENSE' }
	s.authors = { 'andwell' => 'wellguo@hotmail.com' }
	s.homepage = 'https://github.com/andwell/FKGuardUIView'
	s.source = { :git => 'https://github.com/andwell/FKGuardUIView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
	s.requires_arc = true
	s.source_files = 'FKGuardUIView/*.{h,m}'
	s.public_header_files = 'FKGuardUIView/*.{h}'
	s.frameworks = 'Foundation', 'UIKit'

end
