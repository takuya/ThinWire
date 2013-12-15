ThinWire
========

Minal set of  TripeWrire . ThinWire check file Hash and report if changed.


Usage: Simple Check
=============

	require 'thinwire.rb'
	tw = ThinWire.new
	tw.start()

Usage: Select Checking file
==============

To chagen file watching, set path in constructor.

	require 'thinwire.rb'
	tw = ThinWire.new("/var/www/example.com")
	tw.start()


Ussage: Reports by MAIL
============

To Chage report destination.
Add callback to class to report mail



	tw.report = Proc.new{|msg|
		require 'mail'
		options = { :address              => "smtp.gmail.com",
		         :port                 => 587,
		         :user_name            => 'takuya@example.com'
		         :password             => '***',
		         :authentication       => 'plain',
		         :enable_starttls_auto => true  }
		Mail.defaults do
		delivery_method :smtp, options
		end
		mail = Mail.new do
			from     'takuya@example.com'
			to       'takuya@example.com'
		subject  "ThinWire reports"
		body      msg
		end
		mail.deliver!
		puts :end
	}
	tw.start()





