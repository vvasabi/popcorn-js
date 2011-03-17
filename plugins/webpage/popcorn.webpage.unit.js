test("Popcorn Webpage Plugin", function () {
  
  var popped = Popcorn("#video"),
      expects = 10, 
      count = 0,
      theiFrame = document.getElementsByTagName('iframe');

  expect(expects);
  
  function plus() {
    if ( ++count===expects) {
      start();
    }
  }
  
  stop();
   
  ok ('webpage' in popped, "webpages is a mehtod of the popped instance");
  plus();
  
  equals (theiFrame.length, 0, "initially, there is no iframes on the page" );
  plus();
  
  popped.webpage({
    id: "webpages-a", 
    start: 0, // seconds
    end: 1, // seconds
    src: 'http://webmademovies.org',
    target: 'webpagediv'
  })
  .webpage({
    id: "webpages-b", 
    start: 1, // seconds
    end: 2, // seconds
    src: 'http://zenit.senecac.on.ca/wiki/index.php/Processing.js',
    target: 'webpagediv'
  })
  .volume(0);

  popped.exec( 0, function() {
    ok (!!theiFrame[0], "iframe was created" );
    plus();
    equals (theiFrame.length, 2, "there is only two iframes on the page" );
    plus();
    equals (theiFrame[0].id, "webpages-a", "the first iframe has the id 'webpages-a'" );
    plus();
    equals (theiFrame[0].src, "http://webmademovies.org/", "iframe has the src 'http://webmademovies.org/'" );
    plus();
  });

  popped.exec( 2, function() {
    ok (theiFrame[0].style.display === 'none' && theiFrame[1].style.display === 'none', "both iframes are hidden" );
    plus();
  });

  popped.exec( 1, function() {
    ok (!!theiFrame[1], "iframe was created" );
    plus();
    equals (theiFrame[1].id, "webpages-b", "iframe second has the id 'webpages-b'" );
    plus();
    equals (theiFrame[1].src,"http://zenit.senecac.on.ca/wiki/index.php/Processing.js", "iframe has the src 'http://zenit.senecac.on.ca/wiki/index.php/Processing.js'" );
    plus();
  });

  popped.play();

});
