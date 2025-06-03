import { createActionGroup, emptyProps, props } from '@ngrx/store';

export const OrderActions = createActionGroup({
  source: 'Order',
  events: {
    'Load Orders': emptyProps(),
    'Load Orders Success': props<{ orders: any[] }>(),
    'Load Orders Failure': props<{ error: string }>(),
    'Load Order Details': props<{ orderId: string }>(),
    'Load Order Details Success': props<{ order: any }>(),
    'Load Order Details Failure': props<{ error: string }>(),
    'Cancel Order': props<{ orderId: string }>(),
    'Cancel Order Success': props<{ orderId: string }>(),
    'Cancel Order Failure': props<{ error: string }>(),
    'Track Order': props<{ orderId: string }>(),
    'Track Order Success': props<{ tracking: any }>(),
    'Track Order Failure': props<{ error: string }>(),
  }
});
