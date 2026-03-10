# Firebase Schema

## Firebase Services

- Firebase Auth
- Firestore
- Storage
- FCM
- Remote Config

---

# Firestore Collections

users
renter_profiles
owner_profiles
listings
listing_media
favorites
interests
chat_requests
chats
messages
visits
assignments
agreements
tenancies
move_in_checklists
move_out_requests
move_out_checklists
invoices
invoice_items
payments
payment_receipts
deposits
reviews
review_reports
notifications
reports
audit_logs

---

# Example Documents

## users

{
userId,
name,
phone,
email,
profilePhoto,
roles,
createdAt
}

---

## listings

{
listingId,
ownerId,
title,
description,
propertyType,
rooms,
floor,
furnishing,
price,
amenities,
approxLocation,
exactAddress,
status,
createdAt
}

---

## agreements

{
agreementId,
listingId,
ownerId,
renterId,
rentAmount,
depositAmount,
startDate,
endDate,
rules,
signedOwner,
signedRenter,
createdAt
}

---

## invoices

{
invoiceId,
tenancyId,
rent,
utilities,
deductions,
total,
status,
dueDate
}

---

## payments

{
paymentId,
invoiceId,
amount,
method,
status,
createdAt
}

---

## reviews

{
reviewId,
reviewerId,
revieweeId,
rating,
comment,
createdAt
}
