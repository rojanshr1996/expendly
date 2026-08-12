/* ==========================================================================
   Expendly Web Application Script
   Interactive UI logic: Theme toggle, Mobile Menu, FAQ Accordion, Forms
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  // 1. Theme Toggle Management
  const themeToggleBtn = document.getElementById('theme-toggle');
  const savedTheme = localStorage.getItem('expendly-theme') || 'dark';

  if (savedTheme === 'light') {
    document.documentElement.setAttribute('data-theme', 'light');
    if (themeToggleBtn) themeToggleBtn.innerHTML = '🌙';
  } else {
    document.documentElement.removeAttribute('data-theme');
    if (themeToggleBtn) themeToggleBtn.innerHTML = '☀️';
  }

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', () => {
      const isLight = document.documentElement.getAttribute('data-theme') === 'light';
      if (isLight) {
        document.documentElement.removeAttribute('data-theme');
        localStorage.setItem('expendly-theme', 'dark');
        themeToggleBtn.innerHTML = '☀️';
      } else {
        document.documentElement.setAttribute('data-theme', 'light');
        localStorage.setItem('expendly-theme', 'light');
        themeToggleBtn.innerHTML = '🌙';
      }
    });
  }

  // 2. Mobile Drawer Navigation Toggle
  const mobileMenuBtn = document.getElementById('mobile-menu-btn');
  const navLinks = document.getElementById('nav-links');

  if (mobileMenuBtn && navLinks) {
    mobileMenuBtn.addEventListener('click', () => {
      navLinks.classList.toggle('mobile-open');
    });

    // Close mobile menu when clicking outside or clicking a link
    document.querySelectorAll('.nav-link').forEach(link => {
      link.addEventListener('click', () => {
        navLinks.classList.remove('mobile-open');
      });
    });
  }

  // 3. FAQ Accordion Toggle
  const faqQuestions = document.querySelectorAll('.faq-question');
  faqQuestions.forEach(q => {
    q.addEventListener('click', () => {
      const answer = q.nextElementSibling;
      const isOpen = answer.style.display === 'block';

      // Close all answers
      document.querySelectorAll('.faq-answer').forEach(a => a.style.display = 'none');
      document.querySelectorAll('.faq-question span.toggle-icon').forEach(i => i.textContent = '+');

      if (!isOpen) {
        answer.style.display = 'block';
        const icon = q.querySelector('.toggle-icon');
        if (icon) icon.textContent = '−';
      }
    });
  });

  // 4. Contact Form Handler
  const contactForm = document.getElementById('contact-form');
  const formStatus = document.getElementById('form-status');

  if (contactForm && formStatus) {
    contactForm.addEventListener('submit', (e) => {
      e.preventDefault();
      
      const submitBtn = contactForm.querySelector('button[type="submit"]');
      const originalText = submitBtn.textContent;
      submitBtn.textContent = 'Sending...';
      submitBtn.disabled = true;

      const name = document.getElementById('name')?.value || '';
      const userEmail = document.getElementById('email')?.value || '';
      const subject = document.getElementById('subject')?.value || 'Support Request';
      const message = document.getElementById('message')?.value || '';

      const targetInbox = 'thoughsphere0' + '@' + 'gmail.com';
      const mailtoUrl = `mailto:${targetInbox}?subject=${encodeURIComponent('[Expendly Support] ' + subject)}&body=${encodeURIComponent('From: ' + name + ' (' + userEmail + ')\n\nMessage:\n' + message)}`;

      setTimeout(() => {
        window.location.href = mailtoUrl;

        formStatus.style.display = 'block';
        formStatus.className = 'callout-box';
        formStatus.style.borderLeftColor = 'var(--color-green)';
        formStatus.innerHTML = '<p style="color: var(--color-green);">Thank you! Your message draft has been prepared for support dispatch.</p>';
        contactForm.reset();
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
      }, 500);
    });
  }

  // 5. Publisher ID Copy Utility
  const copyPubBtn = document.getElementById('copy-pub-id');
  if (copyPubBtn) {
    copyPubBtn.addEventListener('click', () => {
      const textToCopy = 'google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0';
      navigator.clipboard.writeText(textToCopy).then(() => {
        const originalText = copyPubBtn.textContent;
        copyPubBtn.textContent = 'Copied!';
        setTimeout(() => {
          copyPubBtn.textContent = originalText;
        }, 2000);
      });
    });
  }
});
