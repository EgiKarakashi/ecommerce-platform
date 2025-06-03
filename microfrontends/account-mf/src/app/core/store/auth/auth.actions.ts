import { createActionGroup, emptyProps, props } from '@ngrx/store';

export const AuthActions = createActionGroup({
  source: 'Auth',
  events: {
    'Login': props<{ email: string; password: string }>(),
    'Login Success': props<{ user: any; token: string }>(),
    'Login Failure': props<{ error: string }>(),
    'Logout': emptyProps(),
    'Logout Success': emptyProps(),
    'Register': props<{ userData: any }>(),
    'Register Success': props<{ user: any }>(),
    'Register Failure': props<{ error: string }>(),
    'Load User': emptyProps(),
    'Load User Success': props<{ user: any }>(),
    'Load User Failure': props<{ error: string }>(),
    'Update Profile': props<{ userData: any }>(),
    'Update Profile Success': props<{ user: any }>(),
    'Update Profile Failure': props<{ error: string }>(),
    'Change Password': props<{ currentPassword: string; newPassword: string }>(),
    'Change Password Success': emptyProps(),
    'Change Password Failure': props<{ error: string }>(),
    'Forgot Password': props<{ email: string }>(),
    'Forgot Password Success': emptyProps(),
    'Forgot Password Failure': props<{ error: string }>(),
    'Reset Password': props<{ token: string; password: string }>(),
    'Reset Password Success': emptyProps(),
    'Reset Password Failure': props<{ error: string }>(),
  }
});
