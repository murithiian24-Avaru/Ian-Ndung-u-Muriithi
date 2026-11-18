export function formatCurrency(amount: number, currency: string = 'KES'): string {
  return `${currency} ${amount.toLocaleString()}`;
}
