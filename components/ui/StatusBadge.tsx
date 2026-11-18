import React from 'react';
import { RequestStatus } from '../../types';

const statusStyles: Record<string, string> = {
  [RequestStatus.PENDING]: 'bg-amber-100 text-amber-700',
  [RequestStatus.APPROVED]: 'bg-green-100 text-green-700',
  [RequestStatus.REJECTED]: 'bg-red-100 text-red-700',
  [RequestStatus.PAID]: 'bg-blue-100 text-blue-700',
};

interface StatusBadgeProps {
  status: string;
  className?: string;
}

export default function StatusBadge({ status, className = '' }: StatusBadgeProps) {
  const style = statusStyles[status] || 'bg-gray-100 text-gray-600';
  return (
    <span className={`text-xs px-2 py-1 rounded-full ${style} ${className}`}>
      {status}
    </span>
  );
}
