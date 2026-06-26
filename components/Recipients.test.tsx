import React from 'react';
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import Recipients from './Recipients';
import { Recipient, RecipientStatus } from '../types';

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
  {
    id: '3',
    name: 'James Kamau',
    relation: 'Landlord',
    type: 'Service Provider',
    phone: '+254722000111',
    status: RecipientStatus.PENDING,
    trustScore: 60,
  },
];

describe('Recipients', () => {
  it('renders all recipients', () => {
    const setRecipients = vi.fn();
    render(<Recipients recipients={mockRecipients} setRecipients={setRecipients} />);

    expect(screen.getByText('Mama Sarah')).toBeInTheDocument();
    expect(screen.getByText('Nairobi Water Co.')).toBeInTheDocument();
    expect(screen.getByText('James Kamau')).toBeInTheDocument();
  });

  it('renders the page heading', () => {
    const setRecipients = vi.fn();
    render(<Recipients recipients={mockRecipients} setRecipients={setRecipients} />);

    expect(screen.getByText('Trusted Recipients')).toBeInTheDocument();
    expect(screen.getByText('Manage who can receive funds directly.')).toBeInTheDocument();
  });

  it('shows "Verify Identity" button only for pending recipients', () => {
    const setRecipients = vi.fn();
    render(<Recipients recipients={mockRecipients} setRecipients={setRecipients} />);

    const verifyButtons = screen.getAllByText('Verify Identity');
    expect(verifyButtons).toHaveLength(1); // Only James Kamau is PENDING
  });

  it('shows "Verified & Secure" for verified recipients', () => {
    const setRecipients = vi.fn();
    render(<Recipients recipients={mockRecipients} setRecipients={setRecipients} />);

    const verifiedButtons = screen.getAllByText('Verified & Secure');
    expect(verifiedButtons).toHaveLength(2); // Mama Sarah and Nairobi Water
  });

  it('displays recipient details (type, phone, relation)', () => {
    const setRecipients = vi.fn();
    render(<Recipients recipients={mockRecipients} setRecipients={setRecipients} />);

    expect(screen.getByText('Mother')).toBeInTheDocument();
    expect(screen.getByText('+254712345678')).toBeInTheDocument();
    expect(screen.getByText('Landlord')).toBeInTheDocument();
  });

  it('opens the Add Recipient modal when clicking Add New', async () => {
    const setRecipients = vi.fn();
    const user = userEvent.setup();
    render(<Recipients recipients={mockRecipients} setRecipients={setRecipients} />);

    await user.click(screen.getByText('Add New'));
    expect(screen.getByText('Add Trusted Recipient')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Full Name / Company Name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('M-Pesa Number / Paybill')).toBeInTheDocument();
  });

  it('closes the modal when Cancel is clicked', async () => {
    const setRecipients = vi.fn();
    const user = userEvent.setup();
    render(<Recipients recipients={mockRecipients} setRecipients={setRecipients} />);

    await user.click(screen.getByText('Add New'));
    expect(screen.getByText('Add Trusted Recipient')).toBeInTheDocument();

    await user.click(screen.getByText('Cancel'));
    expect(screen.queryByText('Add Trusted Recipient')).not.toBeInTheDocument();
  });

  it('calls setRecipients when a new recipient is added', async () => {
    const setRecipients = vi.fn();
    const user = userEvent.setup();
    render(<Recipients recipients={mockRecipients} setRecipients={setRecipients} />);

    await user.click(screen.getByText('Add New'));
    await user.type(screen.getByPlaceholderText('Full Name / Company Name'), 'Test Person');
    await user.type(screen.getByPlaceholderText('Relation (e.g., Mom)'), 'Brother');
    await user.type(screen.getByPlaceholderText('M-Pesa Number / Paybill'), '+254700000000');
    await user.click(screen.getByText('Add & Verify'));

    expect(setRecipients).toHaveBeenCalledTimes(1);
    const newList = setRecipients.mock.calls[0][0];
    expect(newList).toHaveLength(mockRecipients.length + 1);
    const added = newList[newList.length - 1];
    expect(added.name).toBe('Test Person');
    expect(added.status).toBe(RecipientStatus.PENDING);
    expect(added.trustScore).toBe(50);
  });

  it('renders correctly with empty recipients list', () => {
    const setRecipients = vi.fn();
    render(<Recipients recipients={[]} setRecipients={setRecipients} />);

    expect(screen.getByText('Trusted Recipients')).toBeInTheDocument();
    expect(screen.queryByText('Verify Identity')).not.toBeInTheDocument();
  });

  it('calls setRecipients when verifying a pending recipient', () => {
    vi.useFakeTimers();
    const setRecipients = vi.fn();
    render(<Recipients recipients={mockRecipients} setRecipients={setRecipients} />);

    fireEvent.click(screen.getByText('Verify Identity'));

    // The verification uses setTimeout with 1000ms delay
    vi.advanceTimersByTime(1000);

    expect(setRecipients).toHaveBeenCalledTimes(1);
    const updatedList = setRecipients.mock.calls[0][0];
    const verifiedRecipient = updatedList.find((r: Recipient) => r.id === '3');
    expect(verifiedRecipient.status).toBe(RecipientStatus.VERIFIED);
    expect(verifiedRecipient.trustScore).toBe(80);

    vi.useRealTimers();
  });
});
