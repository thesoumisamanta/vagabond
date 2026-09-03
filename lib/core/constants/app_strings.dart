class AppStrings {
  // General App Strings
  static const String appTitle = 'Vagabond';

  // Register Screen Strings
  static const String registerCreateAccount = 'Create Account';
  static const String registerSubtitle = 'Join Vagabond and start exploring';
  static const String registerFullNameLabel = 'Full Name';
  static const String registerFullNameHint = 'Enter your full name';
  static const String registerFullNameRequired = 'Please enter your full name';
  static const String registerEmailLabel = 'Email ID';
  static const String registerEmailHint = 'Enter your email';
  static const String registerEmailRequired = 'Please enter your email';
  static const String registerEmailInvalid = 'Please enter a valid email';
  static const String registerUsernameLabel = 'Username';
  static const String registerUsernameHint = 'Enter your username';
  static const String registerUsernameRequired = 'Please enter your username';
  static const String registerPasswordLabel = 'Password';
  static const String registerPasswordHint = 'Enter your password';
  static const String registerPasswordRequired = 'Please enter your password';
  static const String registerPasswordTooShort = 'Password must be at least 6 characters';
  static const String registerConfirmPasswordLabel = 'Confirm Password';
  static const String registerConfirmPasswordHint = 'Confirm your password';
  static const String registerConfirmPasswordRequired = 'Please confirm your new password';
  static const String registerPasswordsDoNotMatch = 'Passwords do not match';
  static const String registerAccountTypeLabel = 'Account Type';
  static const String registerAccountTypePersonal = 'Personal';
  static const String registerAccountTypeBusiness = 'Business';
  static const String registerButton = 'Register';
  static const String registerAlreadyHaveAccount = 'Already have an account? ';
  static const String registerLoginLink = 'Login';

  // Login Screen Strings
  static const String loginWelcomeBack = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue your journey';
  static const String loginUsernameLabel = 'Username';
  static const String loginUsernameHint = 'Enter your username';
  static const String loginUsernameRequired = 'Please enter your username';
  static const String loginPasswordLabel = 'Password';
  static const String loginPasswordHint = 'Enter your password';
  static const String loginPasswordRequired = 'Please enter your password';
  static const String loginButton = 'Login';
  static const String loginDontHaveAccount = "Don't have an account? ";
  static const String loginRegisterLink = 'Register';
  static const String loginSuccessMessage = 'Login successful';

  // OTP Screen Strings
  static const String otpVerifyEmail = 'Verify Email';
  static const String otpSubtitlePrefix = 'We sent a 6-digit verification code to\n';
  static const String otpRequired = 'Please enter the 6-digit code';
  static const String otpVerifyButton = 'Verify Code';
  static const String otpDidNotReceive = "Didn't receive the code? ";
  static const String otpResendLink = 'Resend';
  static const String otpBackToRegister = 'Back to Register';

  // Change Password Screen Strings
  static const String changePasswordTitle = 'Change Password';
  static const String changePasswordHeaderTitle = 'Update Password';
  static const String changePasswordSubtitle = 'Ensure your account is using a long, random password to stay secure.';
  static const String changePasswordCurrentLabel = 'Current Password';
  static const String changePasswordCurrentHint = 'Enter your current password';
  static const String changePasswordCurrentRequired = 'Please enter your current password';
  static const String changePasswordNewLabel = 'New Password';
  static const String changePasswordNewHint = 'Enter your new password';
  static const String changePasswordNewRequired = 'Please enter your new password';
  static const String changePasswordNewTooShort = 'Password must be at least 6 characters';
  static const String changePasswordConfirmLabel = 'Confirm New Password';
  static const String changePasswordConfirmHint = 'Confirm your new password';
  static const String changePasswordConfirmRequired = 'Please confirm your new password';
  static const String changePasswordPasswordsDoNotMatch = 'Passwords do not match';
  static const String changePasswordButton = 'Change Password';

  // Delete Account Screen Strings
  static const String deleteAccountTitle = 'Delete Account';
  static const String deleteAccountHeaderTitle = 'Are you absolutely sure?';
  static const String deleteAccountSubtitle =
      'This action is permanent and cannot be undone. All your data, posts, and profile information will be permanently deleted.';
  static const String deleteAccountPasswordLabel = 'Password';
  static const String deleteAccountPasswordHint = 'Enter your password to confirm';
  static const String deleteAccountPasswordRequired = 'Please enter your password';
  static const String deleteAccountButton = 'Delete Account';

  // Settings Screen Strings
  static const String settingsTitle = 'Settings';
  static const String settingsChangePassword = 'Change Password';
  static const String settingsPrivacySettings = 'Privacy Settings';
  static const String settingsDeleteAccount = 'Delete Account';

  // Privacy Settings Screen Strings
  static const String privacySettingsTitle = 'Privacy Settings';
  static const String privacySettingsPrivateAccount = 'Private Account';
  static const String privacySettingsSubtitle =
      "When your account is private, only people you approve can see your photos, videos, and profile details. Your existing followers won't be affected.";

  // Home Screen Strings
  static const String homeRetry = 'Retry';
  static const String homeNoPostsYet = 'No posts yet.\nBe the first to share your journey!';
  static const String homeYourStory = 'Your Story';
  static const String homeStoryViewerBarrierLabel = 'StoryViewer';
  static const String homeJustNow = 'Just now';
  static const String homeMinutesAgo = 'm ago';
  static const String homeHoursAgo = 'h ago';
  static const String homeDaysAgo = 'd ago';
  static const String homeDay = 'day';
  static const String homeDays = 'days';
  static const String homeHour = 'hour';
  static const String homeHours = 'hours';
  static const String homeMinute = 'minute';
  static const String homeMinutes = 'minutes';
  static const String homeAgo = 'ago';
  static const String homeLike = 'like';
  static const String homeLikes = 'likes';
  static const String homeDislike = 'dislike';
  static const String homeDislikes = 'dislikes';
  static const String homeViewAll = 'View all ';
  static const String homeComments = ' comments';
  static const String homeSharePrefix = 'Check out this post on Vagabond! ';
  static const String homeShareSubject = 'Check out this Vagabond post!';

  // Menu Screen Strings
  static const String menuTitle = 'Menu';
  static const String menuSettings = 'Settings';
  static const String menuHelpSupport = 'Help & Support';
  static const String menuPrivacyPolicy = 'Privacy Policy';
  static const String menuTermsConditions = 'Terms & Conditions';
  static const String menuLogout = 'Logout';
  static const String menuLogoutConfirmTitle = 'Logout';
  static const String menuLogoutConfirmMessage = 'Are you sure you want to log out of your account?';
  static const String menuCancel = 'Cancel';

  // Dashboard Screen Strings
  static const String dashboardTitle = 'VAGABOND';
  static const String dashboardReelsTitle = 'Reels';
  static const String dashboardReelsSubtitle = 'Watch short, engaging travel videos and moments.';
  static const String dashboardChatsTitle = 'Chats';
  static const String dashboardChatsSubtitle = 'Connect and chat with fellow explorers.';
  static const String dashboardHomeLabel = 'Home';
  static const String dashboardReelsLabel = 'Reels';
  static const String dashboardAddPostLabel = 'Add Post';
  static const String dashboardChatsLabel = 'Chats';
  static const String dashboardMenuLabel = 'Menu';

  // Legal Strings
  static const String legalPrivacyPolicyTitle = 'Privacy Policy';
  static const String legalTermsConditionsTitle = 'Terms & Conditions';
  static const String legalRetry = 'Retry';
  static const String legalInfoWeCollect = 'Information We Collect';
  static const String legalHowWeUseInfo = 'How We Use Information';
  static const String legalThirdPartyServices = 'Third-Party Services';
  static const String legalYourDataRights = 'Your Data Rights';
  static const String legalIntroduction = 'Introduction';
  static const String legalUserAccounts = 'User Accounts';
  static const String legalContentGuidelines = 'Content Guidelines';
  static const String legalTermination = 'Termination';
  static const String legalGoverningLaw = 'Governing Law';
  static const String legalVersionPrefix = 'Version: ';
  static const String legalEffectivePrefix = 'Effective: ';

  // Post Strings
  static const String postMaxMediaError = 'You can only add up to 10 media files.';
  static const String postCreateTitle = 'Create Post';
  static const String postButton = 'Post';
  static const String postCaptionLabel = 'Caption';
  static const String postLocationLabel = 'Location (e.g. Tokyo, Japan)';
  static const String postTagsLabel = 'Tags (e.g. japan, travel, fuji)';
  static const String postDetailsTitle = 'Post Details';
  static const String postMediaPrefix = 'Media (';
  static const String postMediaSuffix = '/10)';
  static const String postPhotoLabel = 'Photo';
  static const String postVideoLabel = 'Video';
  static const String postAddMediaPlaceholder = 'Tap Photo or Video to add media';

  // Search Strings
  static const String searchTitle = 'Search';
  static const String searchHint = 'Search users by name or username...';
  static const String searchNoUsersFound = 'No users found.';
  static const String searchFollowersTitle = 'Followers';
  static const String searchFollowingTitle = 'Following';
  static const String searchNoFollowers = 'No followers yet.';
  static const String searchNoFollowing = 'Not following anyone yet.';
  static const String searchUnfollowTitle = 'Unfollow User';
  static const String searchUnfollowConfirmPrefix = 'Are you sure you want to unfollow @';
  static const String searchUnfollowConfirmSuffix = '?';
  static const String searchCancel = 'Cancel';
  static const String searchUnfollowButton = 'Unfollow';
  static const String searchProfileTitle = 'Profile';
  static const String searchPrivateAccountTitle = 'This Account is Private';
  static const String searchPrivateAccountSubtitle = 'Follow this user to see their followers and following.';
  static const String searchFollowingButton = 'Following';
  static const String searchFollowButton = 'Follow';
  static const String searchPostsStat = 'Posts';
  static const String searchFollowersStat = 'Followers';
  static const String searchFollowingStat = 'Following';
  static const String searchInitialPlaceholder = 'Search for travelers...';
  static const String searchDefaultInputHint = 'Search...';

  // Splash Strings
  static const String splashAppName = 'VAGABOND';
  static const String splashSubtitle = 'Your Ultimate Journey Companion';

  // Comment Strings
  static const String commentsTitle = 'Comments';
  static const String commentsNoComments = 'No comments yet. Be the first to comment!';
  static const String commentsAddCommentHint = 'Add a comment...';
  static const String commentsReplyingTo = 'Replying to @';
  static const String commentsEditingComment = 'Editing comment';
  static const String commentsViewMoreReplies = 'View more replies';
  static const String commentsViewReplies = 'View replies';

  // Notification Strings
  static const String notificationsTitle = 'Notifications';
  static const String notificationsReadAll = 'Read All';
  static const String notificationsNoNotifications = 'No notifications yet';
  static const String notificationsJustNow = 'Just now';
  static const String notificationsDaysAgo = 'd ago';
  static const String notificationsHoursAgo = 'h ago';
  static const String notificationsMinutesAgo = 'm ago';

  // Chat Strings
  static const String chatGallery = 'Gallery';
  static const String chatVideo = 'Video';
  static const String chatUnsendMessage = 'Unsend Message';
  static const String chatLoading = 'Loading...';
  static const String chatOnline = 'Online';
  static const String chatOffline = 'Offline';
  static const String chatSomeone = 'Someone';
  static const String chatIsTyping = 'is typing...';
  static const String chatAcceptRequestPrompt = 'Accept message request to start chatting?';
  static const String chatDecline = 'Decline';
  static const String chatAccept = 'Accept';
  static const String chatTypeMessageHint = 'Type a message...';
  static const String chatInboxTitle = 'Chats';
  static const String chatRetry = 'Retry';
  static const String chatNoConversations = 'No conversations yet.';
  static const String chatSentMediaMessage = 'Sent a media message';
  static const String chatNoMessagesYet = 'No messages yet';
}
