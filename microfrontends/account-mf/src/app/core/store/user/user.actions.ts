import { createActionGroup, emptyProps, props } from '@ngrx/store';

export const UserActions = createActionGroup({
  source: 'User',
  events: {
    'Load User Data': emptyProps(),
    'Load User Data Success': props<{ userData: any }>(),
    'Load User Data Failure': props<{ error: string }>(),
    'Update Profile': props<{ userData: any }>(),
    'Update Profile Success': props<{ user: any }>(),
    'Update Profile Failure': props<{ error: string }>(),
    'Upload Avatar': props<{ file: File }>(),
    'Upload Avatar Success': props<{ avatarUrl: string }>(),
    'Upload Avatar Failure': props<{ error: string }>(),
  }
});
