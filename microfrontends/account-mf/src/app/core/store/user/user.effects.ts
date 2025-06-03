import { Injectable } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, exhaustMap, catchError } from 'rxjs/operators';
import { UserActions } from './user.actions';
import { UserService } from '../../services/user.service';

@Injectable()
export class UserEffects {
  constructor(
    private actions$: Actions,
    private userService: UserService
  ) {}

  updateProfile$ = createEffect(() =>
    this.actions$.pipe(
      ofType(UserActions.updateProfile),
      exhaustMap(action =>
        this.userService.updateProfile(action.userData).pipe(
          map(user => UserActions.updateProfileSuccess({ user })),
          catchError(error => of(UserActions.updateProfileFailure({
            error: error.error?.message || 'Profile update failed'
          })))
        )
      )
    )
  );

  loadUserData$ = createEffect(() =>
    this.actions$.pipe(
      ofType(UserActions.loadUserData),
      exhaustMap(() =>
        this.userService.getUserData().pipe(
          map(userData => UserActions.loadUserDataSuccess({ userData })),
          catchError(error => of(UserActions.loadUserDataFailure({
            error: error.error?.message || 'Failed to load user data'
          })))
        )
      )
    )
  );
}
