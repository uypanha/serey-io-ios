RE.editor.addEventListener("paste", function(e) {
                           console.log("on paste");
                           e.preventDefault();
                           if ((e.originalEvent || e).clipboardData.getData('text/html')) {
                           var text = (e.originalEvent || e).clipboardData.getData('text/html');
                           
                           var $result = $('<div></div>').append($(text));
                           
                           $.each($result.find("*"), function(idx, val) {
                                  var $item = $(val);
                                  if ($item.length > 0) {
                                  var removeStyle = {
                                  'font-stretch': '',
                                  'line-height': '',
                                  'font-weight': '',
                                  'font-family': '',
                                  'font-style': '',
                                  'font-size': '',
                                  'caret-color': '',
                                  'color' : '',
                                  '-webkit-text-stroke-width': '',
                                  '-webkit-text-size-adjust': '',
                                  '-webkit-tap-highlight-color': '',
                                  '-webkit-text-size-adjust' : ''
                                  };
                                  $item.removeAttr('style').css(removeStyle);
                                  }
                                  });
                           text = $result.html();
                           document.execCommand("insertHTML", false, text);
                           } else {
                           var text = (e.originalEvent || e).clipboardData.getData('text/plain');
                           document.execCommand("insertHTML", false, text);
                           }
                           });

RE.insertImage = function(url, alt) {
    var img = document.createElement('img');
    img.setAttribute("width", "100%");
    img.setAttribute("src", url);
    img.setAttribute("alt", alt);
    img.onload = RE.updateHeight;
    
    RE.insertHTML(img.outerHTML);
    RE.callback("input");
};

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
