/**
 * Sidewalk Stories LA - Main JavaScript
 * Handles mobile navigation, scroll effects, animated counters, and form interactions
 */

document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const navbar = document.getElementById('navbar');
    const navToggle = document.querySelector('.nav-toggle');
    const navMenu = document.querySelector('.nav-menu');
    const navLinks = document.querySelectorAll('.nav-menu a');
    const donateButtons = document.querySelectorAll('.donate-btn');
    const statNumbers = document.querySelectorAll('.stat-number');

    // Navbar scroll effect
    function handleScroll() {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    }

    window.addEventListener('scroll', handleScroll);
    handleScroll(); // Check on load

    // Mobile navigation toggle
    if (navToggle) {
        navToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');

            // Animate hamburger to X
            const spans = navToggle.querySelectorAll('span');
            if (navMenu.classList.contains('active')) {
                spans[0].style.transform = 'rotate(45deg) translate(5px, 5px)';
                spans[1].style.opacity = '0';
                spans[2].style.transform = 'rotate(-45deg) translate(5px, -5px)';
            } else {
                spans[0].style.transform = 'none';
                spans[1].style.opacity = '1';
                spans[2].style.transform = 'none';
            }
        });
    }

    // Close mobile menu when a link is clicked
    navLinks.forEach(function(link) {
        link.addEventListener('click', function() {
            if (navMenu.classList.contains('active')) {
                navMenu.classList.remove('active');
                const spans = navToggle.querySelectorAll('span');
                spans[0].style.transform = 'none';
                spans[1].style.opacity = '1';
                spans[2].style.transform = 'none';
            }
        });
    });

    // Close mobile menu when clicking outside
    document.addEventListener('click', function(e) {
        if (navMenu.classList.contains('active') &&
            !navMenu.contains(e.target) &&
            !navToggle.contains(e.target)) {
            navMenu.classList.remove('active');
            const spans = navToggle.querySelectorAll('span');
            spans[0].style.transform = 'none';
            spans[1].style.opacity = '1';
            spans[2].style.transform = 'none';
        }
    });

    // Donation button feedback
    donateButtons.forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const amount = btn.textContent.split('\n')[0];
            alert('Thank you for your interest in donating ' + amount + '!\n\nWe are setting up our donation processor. Please email trevor@sidewalkstoriesla.org with your preferred amount and we will send you a secure payment link.');
        });
    });

    // Form submission handling (placeholder)
    const forms = document.querySelectorAll('form');
    forms.forEach(function(form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            alert('Thank you for reaching out!\n\nWe have received your message and will respond within 48 hours. In the meantime, feel free to email us directly at trevor@sidewalkstoriesla.org.');
            form.reset();
        });
    });

    // Smooth scroll for anchor links (fallback for older browsers)
    document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href !== '#') {
                e.preventDefault();
                const target = document.querySelector(href);
                if (target) {
                    const navHeight = navbar ? navbar.offsetHeight : 0;
                    const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - navHeight;
                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                }
            }
        });
    });

    // Animated Stat Counters
    function animateCounter(element, target, duration) {
        const hasPlus = target.includes('+');
        const hasComma = target.includes(',');
        const hasDollar = target.includes('$');
        const numericValue = parseInt(target.replace(/[^0-9]/g, ''), 10);

        let start = 0;
        const startTime = performance.now();

        function update(currentTime) {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const easeOut = 1 - Math.pow(1 - progress, 3);
            const current = Math.floor(easeOut * numericValue);

            let display = current.toLocaleString();
            if (hasDollar) display = '$' + display;
            if (hasPlus && current >= numericValue) display = display + '+';
            element.textContent = display;

            if (progress < 1) {
                requestAnimationFrame(update);
            } else {
                let final = numericValue.toLocaleString();
                if (hasDollar) final = '$' + final;
                if (hasPlus) final = final + '+';
                element.textContent = final;
            }
        }

        requestAnimationFrame(update);
    }

    const counterObserver = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                const target = entry.target.textContent.trim();
                entry.target.textContent = '0';
                entry.target.classList.add('counter');
                animateCounter(entry.target, target, 2000);
                counterObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    statNumbers.forEach(function(stat) {
        counterObserver.observe(stat);
    });

    // Before/After Slider functionality
    const sliders = document.querySelectorAll('.before-after-slider');
    sliders.forEach(function(slider) {
        const afterImage = slider.querySelector('.after-image');
        const handle = slider.querySelector('.slider-handle');
        if (!afterImage || !handle) return;

        let isDragging = false;

        function updateSlider(clientX) {
            const rect = slider.getBoundingClientRect();
            let x = clientX - rect.left;
            x = Math.max(0, Math.min(x, rect.width));
            const percentage = (x / rect.width) * 100;
            afterImage.style.width = percentage + '%';
            handle.style.left = percentage + '%';
        }

        handle.addEventListener('mousedown', function() { isDragging = true; });
        document.addEventListener('mouseup', function() { isDragging = false; });
        document.addEventListener('mousemove', function(e) {
            if (isDragging) updateSlider(e.clientX);
        });

        handle.addEventListener('touchstart', function() { isDragging = true; });
        document.addEventListener('touchend', function() { isDragging = false; });
        document.addEventListener('touchmove', function(e) {
            if (isDragging && e.touches[0]) updateSlider(e.touches[0].clientX);
        });

        slider.addEventListener('click', function(e) {
            updateSlider(e.clientX);
        });
    });

    // Intersection Observer for fade-in animations on scroll
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe process cards, benefit items, and pilot cards
    const animateElements = document.querySelectorAll('.process-card, .benefit-item, .pilot-card, .gallery-item');
    animateElements.forEach(function(el) {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
});
