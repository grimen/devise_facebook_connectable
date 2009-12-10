/**
 *  JavaScript Helpers for devise_facebook_connectable,
 *  to make connect/login/logout with Devise seamless.
 *  
 *  Note: JavaScript framework agnostic.
 */
 
if (typeof devise === 'undefined' || devise === null) {
  devise = {};
}

if (typeof devise.facebook_connectable === 'undefined' || devise.facebook_connectable === null) {
  devise.facebook_connectable = {};
}

/* 
 *  Connect/Login.
 */
devise.facebook_connectable.login = function fbc_login() {
  document.getElementById('fb_connect_login_form').submit();
  return false;
};

/* 
 *  Connect/Login - with callback.
 */
devise.facebook_connectable.login_with_callback = function fbc_login_with_callback() {
  FB.Connect.requireSession(devise.facebook_connectable.login);
  return false;
};

/* 
 *  Logout.
 */
devise.facebook_connectable.logout = function fbc_logout() {
  document.getElementById('fb_connect_logout_form').submit();
  return false;
};

/* 
 *  Logout - with callback.
 */
devise.facebook_connectable.logout_with_callback = function fbc_logout_with_callback() {
  FB.Connect.logout(devise.facebook_connectable.logout);
  return false;
};

/* 
 *  TODO: Logout.
 */
devise.facebook_connectable.disconnect = function fbc_disconnect() {
  // TODO: Implement
  return false;
};

/* 
 *  TODO: Disconnect - with callback.
 */
devise.facebook_connectable.disconnect_with_callback = function fbc_disconnect_with_callback() {
  // FIXME: FB.api don't seems to be loaded correctly - Facebooker issue?
  // FB.api({method: 'Auth.revokeAuthorization'}, devise.facebook_connectable.disconnect);
  return false;
};
