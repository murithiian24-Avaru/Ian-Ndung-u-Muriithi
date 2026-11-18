import React from 'react';

interface PageHeaderProps {
  title: string;
  description: string;
  className?: string;
}

export default function PageHeader({ title, description, className = 'mb-8' }: PageHeaderProps) {
  return (
    <header className={className}>
      <h1 className="text-2xl font-bold text-gray-900">{title}</h1>
      <p className="text-gray-500 mt-1">{description}</p>
    </header>
  );
}
