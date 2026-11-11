import React from 'react';

const baseInputStyles = 'w-full p-3 border border-gray-200 rounded-lg outline-none focus:ring-2 focus:ring-brand-500';

interface FormInputProps {
  label?: string;
  className?: string;
  type?: string;
  placeholder?: string;
  value?: string | number;
  onChange?: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

export function FormInput({ label, className = '', ...props }: FormInputProps) {
  return (
    <div>
      {label && <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>}
      <input className={`${baseInputStyles} ${className}`} {...props} />
    </div>
  );
}

interface FormSelectProps {
  label?: string;
  className?: string;
  value?: string | number;
  onChange?: (e: React.ChangeEvent<HTMLSelectElement>) => void;
  children: React.ReactNode;
}

export function FormSelect({ label, className = '', children, ...props }: FormSelectProps) {
  return (
    <div>
      {label && <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>}
      <select className={`${baseInputStyles} ${className}`} {...props}>
        {children}
      </select>
    </div>
  );
}

interface FormTextareaProps {
  label?: string;
  className?: string;
  placeholder?: string;
  value?: string;
  onChange?: (e: React.ChangeEvent<HTMLTextAreaElement>) => void;
}

export function FormTextarea({ label, className = '', ...props }: FormTextareaProps) {
  return (
    <div>
      {label && <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>}
      <textarea className={`${baseInputStyles} ${className}`} {...props} />
    </div>
  );
}
