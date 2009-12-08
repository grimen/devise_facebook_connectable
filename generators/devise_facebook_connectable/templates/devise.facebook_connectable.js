/**
 *  Helpers for devise_facebook_connectable, to make connect/login/logout with Devise seamless.
 */
 
if (typeof devise === 'undefined' || devise === null) {
  devise = {};
}

if (typeof devise.facebook_connectable === 'undefined' || devise.facebook_connectable === null) {
  devise.facebook_connectable = {};
}

devise.facebook_connectable.login = function fb_connect_login() {
  document.getElementById('fb_connect_login_form').submit();
  return false;
};

devise.facebook_connectable.custom_login = function fb_connect_custom_login() {
  FB.Connect.requireSession(fb_connect_login);
  return false;
};

devise.facebook_connectable.logout = function fb_connect_logout() {
  document.getElementById('fb_connect_logout_form').submit();
  return false;
};

devise.facebook_connectable.custom_logout = function fb_connect_custom_logout() {
  FB.Connect.logout(fb_connect_logout);
  return false;
};