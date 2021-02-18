package why.email;

import why.Email;
import #if haxe4 js.lib.Promise #else js.Promise #end as JsPromise;

using haxe.io.Path;
using tink.io.Source;
using tink.CoreApi;

#if nodejs
/**
 * Requires the `nodemailer` node package
 * https://nodemailer.com/
 */
class Nodemailer extends EmailBase {
	
	var transporter:Transporter;
	
	public function new(config:TransporterConfig) {
		transporter = NativeNodemailer.createTransport(config);
	}
	
	function doSend(config:EmailConfig):Promise<Noise> {
		return Promise.ofJsPromise(transporter.sendMail({
			from: config.from,
			to: config.to,
			cc: config.cc,
			bcc: config.bcc,
			subject: config.subject,
			text: config.content.text,
			html: config.content.html,
			attachments: {
				var attachments:Array<{}> = [];
				if(config.attachments != null) for(attachment in config.attachments)
					switch attachment.source {
						case Local(path): attachments.push({filename: attachment.filename, path: path});
						case Stream(source): attachments.push({filename: attachment.filename, content: source.toNodeStream()});
					}
				attachments;
			},
		})).noise();
	}
}


@:jsRequire('nodemailer')
extern class NativeNodemailer {
    static function createTransport(opts:TransporterConfig):Transporter;
}

extern class Transporter {
    function sendMail(opts:Dynamic):JsPromise<{}>;
}

typedef TransporterConfig = {
	host:String,
	?port:Int,
	?secure:Bool,
	?auth:{
		user:String,
		pass:String,
	},
}
#end