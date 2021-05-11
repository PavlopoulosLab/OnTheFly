function setCookie(cookie_name, value)
{
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + (365*25));
    document.cookie = cookie_name + "=" + escape(value) + "; expires="+exdate.toUTCString() + "; path=/OnTheFly/";
}

function getCookie(cookie_name)
{
    if (document.cookie.length>0)
    {
        cookie_start = document.cookie.indexOf(cookie_name + "=");
        if (cookie_start != -1)
        {
            cookie_start = cookie_start + cookie_name.length+1;
            cookie_end = document.cookie.indexOf(";",cookie_start);
            if (cookie_end == -1)
            {
                cookie_end = document.cookie.length;
            }
            return unescape(document.cookie.substring(cookie_start,cookie_end));
        }
    }
    return "";
}

$(document).ready(function(){
    setTimeout(function () {
	 if(getCookie('show_cookie_message') != 'no'){
        $("#cookieConsent").fadeIn(200);}
     }, 1500);
    $("#closeCookieConsent").click(function() {
        $("#cookieConsent").fadeOut(200);
    }); 

    $(".cookieConsentOK").click(function() {
        $("#cookieConsent").fadeOut(200);
	setCookie('show_cookie_message','no');
        return false;
    }); 
});
