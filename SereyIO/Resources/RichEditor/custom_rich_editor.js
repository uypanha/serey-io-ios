RE.setHtml = function(contents) {
    console.log("https://serey.io/");
    RE.setBaseUrl("https://serey.io/");
    var tempWrapper = document.createElement('div');
    tempWrapper.innerHTML = contents;
    var images = tempWrapper.querySelectorAll("img");
    
    for (var i = 0; i < images.length; i++) {
        images[i].onload = RE.updateHeight;
    }
    
    RE.editor.innerHTML = tempWrapper.innerHTML;
    RE.updatePlaceholder();
};

RE.setBaseUrl = function(url) {
    $('base').attr('href', url);
};
