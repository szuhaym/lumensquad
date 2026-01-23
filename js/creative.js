/*!
 * Start Bootstrap - Creative Bootstrap Theme (http://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */

(function($) {
    "use strict"; // Start of use strict

    // jQuery for page scrolling feature - requires jQuery Easing plugin
    $('a.page-scroll').bind('click', function(event) {
        event.preventDefault();
        var href = $(this).attr('href') || '';
        var hashIndex = href.indexOf('#');

        // if there's no fragment, treat as a normal link
        if (hashIndex === -1) {
            window.location = href;
            return;
        }

        var fragment = href.substring(hashIndex); // "#about"
        var $target = $(fragment);

        // If element exists on page, animate scroll; otherwise navigate to href
        if ($target.length) {
            $('html, body').stop().animate({
                scrollTop: ($target.offset().top - 50)
            }, 1250, 'easeInOutExpo');
        } else {
            // If no target on current page (likely different page), navigate
            window.location = href;
        }
    });

    // Highlight the top nav as scrolling occurs
    $('body').scrollspy({
        target: '.navbar-fixed-top',
        offset: 51
    })

    // Closes the Responsive Menu on Menu Item Click
    $('.navbar-collapse ul li a').click(function() {
        $('.navbar-toggle:visible').click();
    });

    // Fit Text Plugin for Main Header
    $("h1").fitText(
        1.2, {
            minFontSize: '35px',
            maxFontSize: '65px'
        }
    );

    // Offset for Main Navigation
    $('#mainNav').affix({
        offset: {
            top: 100
        }
    })

    // Initialize WOW.js Scrolling Animations
    new WOW().init();

})(jQuery); // End of use strict
