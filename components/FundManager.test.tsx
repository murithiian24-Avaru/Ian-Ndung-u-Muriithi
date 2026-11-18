import React from 'react';
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import FundManager from './FundManager';
import { Wallet, TransactionCategory, Recipient, RecipientStatus } from '../types';

const mockWallet: Wallet = {
  balance: 250000,
  currency: 'KES',
  allocated: {
    [TransactionCategory.RENT]: 50000,
    [TransactionCategory.SCHOOL_FEES]: 80000,
    [TransactionCategory.SHOPPING]: 20000,
    [TransactionCategory.UTILITIES]: 10000,
    [TransactionCategory.HEALTHCARE]: 30000,
    [TransactionCategory.ALLOWANCE]: 15000,
    [TransactionCategory.EMERGENCY]: 45000,
    [TransactionCategory.GENERAL]: 0,
  },
};

const mockRecipients: Recipient[] = [
  {
    id: '1',
    name: 'Mama Sarah',
    relation: 'Mother',
    type: 'Family',
    phone: '+254712345678',
    status: RecipientStatus.VERIFIED,
    trustScore: 98,
  },
  {
    id: '2',
    name: 'Nairobi Water Co.',
    relation: 'Utility',
    type: 'Service Provider',
    phone: 'Paybill 555123',
    status: RecipientStatus.VERIFIED,
    trustScore: 100,
  },
];

describe('FundManager', () => {
  it('renders the page heading', () => {
    const setWallet = vi.fn();
    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    expect(screen.getByText('Controlled Funds')).toBeInTheDocument();
    expect(screen.getByText('Direct money to specific categories. It cannot be used elsewhere.')).toBeInTheDocument();
  });

  it('displays the wallet balance', () => {
    const setWallet = vi.fn();
    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    expect(screen.getByText('KES 250,000')).toBeInTheDocument();
  });

  it('renders category dropdown with all categories', () => {
    const setWallet = vi.fn();
    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    // The label is not associated with the select via htmlFor, so query directly
    expect(screen.getByText('Category')).toBeInTheDocument();

    Object.values(TransactionCategory).forEach((cat) => {
      expect(screen.getByRole('option', { name: cat })).toBeInTheDocument();
    });
  });

  it('renders recipient dropdown with all recipients', () => {
    const setWallet = vi.fn();
    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    expect(screen.getByText('Select a Trusted Recipient')).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'Mama Sarah (Mother)' })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'Nairobi Water Co. (Utility)' })).toBeInTheDocument();
  });

  it('shows current category balances', () => {
    const setWallet = vi.fn();
    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    expect(screen.getByText('Current Category Balances')).toBeInTheDocument();
    expect(screen.getByText('KES 50,000')).toBeInTheDocument(); // Rent
    expect(screen.getByText('KES 80,000')).toBeInTheDocument(); // School Fees
  });

  it('has disabled submit button when amount or recipient is empty', () => {
    const setWallet = vi.fn();
    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    const submitButton = screen.getByText('Authorize Transaction');
    expect(submitButton).toBeDisabled();
  });

  it('enables submit button when amount and recipient are filled', async () => {
    const setWallet = vi.fn();
    const user = userEvent.setup();
    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    const amountInput = screen.getByPlaceholderText('0.00');
    await user.type(amountInput, '5000');

    // Select a recipient — get all selects and pick the one with the placeholder option
    const selects = screen.getAllByRole('combobox');
    const recipientSelect = selects.find(s => within(s).queryByText('Select a Trusted Recipient'));
    await user.selectOptions(recipientSelect!, '1');

    const submitButton = screen.getByText('Authorize Transaction');
    expect(submitButton).not.toBeDisabled();
  });

  it('calls setWallet after successful fund send', async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    const setWallet = vi.fn();
    const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });

    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    const amountInput = screen.getByPlaceholderText('0.00');
    await user.type(amountInput, '5000');

    const selects = screen.getAllByRole('combobox');
    const recipientSelect = selects.find(s => within(s).queryByText('Select a Trusted Recipient'));
    await user.selectOptions(recipientSelect!, '1');

    const submitButton = screen.getByText('Authorize Transaction');
    await user.click(submitButton);

    expect(screen.getByText('Processing Securely...')).toBeInTheDocument();

    vi.advanceTimersByTime(1500);

    expect(setWallet).toHaveBeenCalledTimes(1);
    const newWallet = setWallet.mock.calls[0][0];
    expect(newWallet.balance).toBe(245000);
    expect(newWallet.allocated[TransactionCategory.RENT]).toBe(55000);

    vi.useRealTimers();
  });

  it('renders the note textarea', () => {
    const setWallet = vi.fn();
    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    expect(screen.getByPlaceholderText('e.g., Paybill for October Rent')).toBeInTheDocument();
  });

  it('displays the available to allocate section', () => {
    const setWallet = vi.fn();
    render(<FundManager wallet={mockWallet} setWallet={setWallet} recipients={mockRecipients} />);

    expect(screen.getByText('Available to Allocate')).toBeInTheDocument();
  });
});
