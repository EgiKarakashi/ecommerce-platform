import { Injectable } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, exhaustMap, catchError } from 'rxjs/operators';
import { OrderActions } from './order.actions';
import { OrderService } from '../../services/order.service';

@Injectable()
export class OrderEffects {
  constructor(
    private actions$: Actions,
    private orderService: OrderService
  ) {}

  loadOrders$ = createEffect(() =>
    this.actions$.pipe(
      ofType(OrderActions.loadOrders),
      exhaustMap(() =>
        this.orderService.getUserOrders().pipe(
          map(orders => OrderActions.loadOrdersSuccess({ orders })),
          catchError(error => of(OrderActions.loadOrdersFailure({
            error: error.error?.message || 'Failed to load orders'
          })))
        )
      )
    )
  );

  loadOrderDetails$ = createEffect(() =>
    this.actions$.pipe(
      ofType(OrderActions.loadOrderDetails),
      exhaustMap(action =>
        this.orderService.getOrderDetails(action.orderId).pipe(
          map(order => OrderActions.loadOrderDetailsSuccess({ order })),
          catchError(error => of(OrderActions.loadOrderDetailsFailure({
            error: error.error?.message || 'Failed to load order details'
          })))
        )
      )
    )
  );

  cancelOrder$ = createEffect(() =>
    this.actions$.pipe(
      ofType(OrderActions.cancelOrder),
      exhaustMap(action =>
        this.orderService.cancelOrder(action.orderId).pipe(
          map(() => OrderActions.cancelOrderSuccess({ orderId: action.orderId })),
          catchError(error => of(OrderActions.cancelOrderFailure({
            error: error.error?.message || 'Failed to cancel order'
          })))
        )
      )
    )
  );
}
