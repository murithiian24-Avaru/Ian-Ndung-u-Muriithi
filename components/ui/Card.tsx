import React from 'react';

interface CardProps {
  children: React.ReactNode;
  className?: string;
  padding?: 'sm' | 'md' | 'lg';
  shadow?: 'sm' | 'md' | 'lg' | 'xl';
}

const paddingMap = {
  sm: 'p-4',
  md: 'p-6',
  lg: 'p-8',
};

const shadowMap = {
  sm: 'shadow-sm',
  md: 'shadow-md',
  lg: 'shadow-lg',
  xl: 'shadow-xl',
};

export default function Card({ children, className = '', padding = 'md', shadow = 'sm' }: CardProps) {
  return (
    <div className={`bg-white rounded-2xl ${shadowMap[shadow]} border border-gray-100 ${paddingMap[padding]} ${className}`}>
      {children}
    </div>
  );
}
