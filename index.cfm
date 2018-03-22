<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>WaterBearCycles Trading</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <link href="https://fonts.googleapis.com/css?family=Lato" rel="stylesheet" type="text/css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
  <link href="css/style.css" rel="stylesheet" type="text/css">
</head>

<body id="myPage" data-spy="scroll" data-target=".navbar" data-offset="50">
  <div class="header">
    <a href="#myPage"><img id="brandLogo" src="images/logo.png" alt="Water Bear Cycles Trading"></a>
  </div>
  <div><cfinclude template="topnav.cfm"></div>
  <div><cfinclude template="carousel.cfm"></div>
  <div class="container text-center">
      <h1>Cash for Bicycles &amp; Bicycle Components</h1>
      <p>Please click on Get Cash button below or Contact us.</p>
  </div>

  <div id="howitworks" class="container"> 
    <cfinclude  template="howitworks.cfm">
  </div>

  <div id="about" class="container">
    <cfinclude  template="about.cfm">
  </div>

  <div id ="contact" class="container text-center">
    <cfinclude template="contact.cfm">
  </div>

  <div id="shipping" class="container text-center">
    <cfinclude template="shipping.cfm">
  </div>

  <div id="consignmentfees" class="container">
    <cfinclude  template="consignmentfees.cfm">
  </div>

  <div><cfinclude template="footer.cfm"></div>
  <script>
    $(document).ready(function(){
      // Add smooth scrolling to all links in navbar + footer link
      $(".navbar a, footer a[href='#myPage']").on('click', function(event) {

      // Make sure this.hash has a value before overriding default behavior
      if (this.hash !== "") {

        // Prevent default anchor click behavior
        event.preventDefault();

        // Store hash
        var hash = this.hash;

        // Using jQuery's animate() method to add smooth page scroll
        // The optional number (900) specifies the number of milliseconds it takes to scroll to the specified area
        $('html, body').animate({
          scrollTop: $(hash).offset().top
        }, 700, function(){

          // Add hash (#) to URL when done scrolling (default click behavior)
          window.location.hash = hash;
          });
        } // End if
      });
    })
  </script>
</body>
</html>
