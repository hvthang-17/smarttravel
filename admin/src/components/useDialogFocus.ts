import { useEffect, useRef } from 'react';

export function useDialogFocus(open: boolean) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!open) return;
    const previous = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    const panel = ref.current;
    if (!panel) return;
    const selector = 'button:not(:disabled), input:not(:disabled):not([type="hidden"]), select:not(:disabled), textarea:not(:disabled), a[href], [tabindex="0"]';
    const frame = requestAnimationFrame(() => {
      const input = panel.querySelector<HTMLElement>('input:not(:disabled):not([type="hidden"]):not([type="file"]), select:not(:disabled), textarea:not(:disabled)');
      (input ?? panel.querySelector<HTMLElement>(selector))?.focus();
    });
    const trap = (event: KeyboardEvent) => {
      if (event.key !== 'Tab') return;
      const controls = [...panel.querySelectorAll<HTMLElement>(selector)]
        .filter(element => element.getClientRects().length > 0);
      const first = controls[0], last = controls[controls.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault(); last?.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault(); first?.focus();
      }
    };
    panel.addEventListener('keydown', trap);
    return () => {
      cancelAnimationFrame(frame);
      panel.removeEventListener('keydown', trap);
      if (previous?.isConnected) previous.focus();
    };
  }, [open]);
  return ref;
}
