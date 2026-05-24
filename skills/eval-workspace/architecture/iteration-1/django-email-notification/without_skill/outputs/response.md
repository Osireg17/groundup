# Baseline Response — Django Email Notification (No Skill)

Great first ticket — email notifications on order ship are a classic Django task. Here's how I'd approach getting oriented and then implementing this.

**Step 1: Understand the existing system**

Before writing anything, explore the codebase:

- `orders/models.py` — Look for an `Order` model with a `status` field (e.g. `"shipped"`)
- `orders/views.py` or a service layer — Where does order status get updated?
- `orders/signals.py` — May already exist if they use Django signals
- `accounts/models.py` — Find the User model / customer email field
- `settings.py` — Email backend config (`EMAIL_BACKEND`, `EMAIL_HOST`, etc.)

**Step 2: Find where order status changes**

```bash
grep -r "shipped" orders/ --include="*.py"
grep -r "status" orders/models.py
grep -r "send_mail\|EmailMessage" . --include="*.py"
```

The last grep tells you if there's already an email utility to follow.

**Step 3: Decide the pattern — signals vs. direct call**

Check how existing side effects are handled in the codebase. Two common patterns:

- Django `post_save` signal on `Order` — decoupled, fires automatically when status changes
- Direct `send_mail()` call in the view or service that updates the status — explicit, easier to trace

Follow whichever pattern already exists in the project.

**Step 4: Implement and test**

Once you know the pattern, implement the notification and write a test using `unittest.mock.patch` on `django.core.mail.send_mail` to verify it fires exactly once when status becomes `"shipped"` and not for other status transitions.

Start by reading `orders/models.py` — what does the `Order` model look like, and how is status currently being updated?
