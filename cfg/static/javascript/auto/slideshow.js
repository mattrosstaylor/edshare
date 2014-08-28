var delay = 5000;
var start_frame = 0;

function init_slideshow() {
	if(!$('edshare_slideshow')){ return; }
	var images = $('edshare_slideshow').getElementsByTagName('img');

	for(i=0; i < images.length; i++){
		if(i!=0){
			images[i].style.display = 'none';
		}
	}

	end_frame = images.length -1;
	
	start_slideshow(start_frame, end_frame);
}

function start_slideshow(start_frame, end_frame) {
	setTimeout(fadeInOut(start_frame,start_frame,end_frame), delay);
}

function fadeInOut(frame, start_frame, end_frame) {
	return (function() {
		images = $('edshare_slideshow').getElementsByTagName('img');
		Effect.Fade(images[frame]);
		if (frame == end_frame) { frame = start_frame; } else { frame++; }
		imageAppear = images[frame]; 
		setTimeout("Effect.Appear(imageAppear);", 0); 
		setTimeout(fadeInOut(frame, start_frame, end_frame, delay), delay + 3000);
	})
	
}

document.observe('dom:loaded', init_slideshow);

