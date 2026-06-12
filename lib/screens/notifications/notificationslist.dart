import 'package:flutter/material.dart';
import 'package:gladskin_backend/models/notification_model.dart';
import 'package:gladskin_backend/services/firestore_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {

  final FirestoreService _firestore =
      FirestoreService();

  final TextEditingController
      _titleController =
          TextEditingController();

  final TextEditingController
      _bodyController =
          TextEditingController();

  bool _isScheduled = false;

DateTime? _scheduledDateTime;

Future<void> _pickScheduleDateTime() async {

  final date =
      await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(
      DateTime.now().year + 2,
    ),
  );

  if (date == null) return;

  final time =
      await showTimePicker(
    context: context,
    initialTime:
        TimeOfDay.now(),
  );

  if (time == null) return;

  setState(() {

    _scheduledDateTime =
        DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  });
}


  Future<void> _sendNotification() async {

  if (_titleController.text
          .trim()
          .isEmpty ||
      _bodyController.text
          .trim()
          .isEmpty) {
    return;
  }

  await _firestore
      .createNotification(

    title:
        _titleController.text.trim(),

    body:
        _bodyController.text.trim(),

    sendType:
        _isScheduled
            ? "scheduled"
            : "instant",

    scheduledAt:
        _isScheduled
            ? _scheduledDateTime
            : null,
  );

  _titleController.clear();
  _bodyController.clear();

  _isScheduled = false;
  _scheduledDateTime = null;

  if (!mounted) return;

  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(
        _isScheduled
            ? "Notification scheduled"
            : "Notification queued",
      ),
    ),
  );
}

  Future<void> _showCreateNotificationSheet() async {

  _titleController.clear();
  _bodyController.clear();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {

      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom:
              MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                  24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              "Create Notification",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  _titleController,
              decoration:
                  const InputDecoration(
                labelText: "Title",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  _bodyController,
              maxLines: 5,
              decoration:
                  const InputDecoration(
                labelText: "Message",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const SizedBox(height: 20),

Container(
  padding:
      const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color:
        const Color(0xFFF8F4F4),
    borderRadius:
        BorderRadius.circular(12),
  ),
  child: Column(
    children: [

      SwitchListTile(
        contentPadding:
            EdgeInsets.zero,
        title: const Text(
          "Schedule Notification",
        ),
        subtitle: const Text(
          "Send later",
        ),
        value: _isScheduled,
        onChanged: (value) {
          setState(() {
            _isScheduled =
                value;
          });
        },
      ),

      if (_isScheduled) ...[

        const SizedBox(
          height: 12,
        ),

        InkWell(
          onTap:
              _pickScheduleDateTime,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          child: Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              14,
            ),
            decoration:
                BoxDecoration(
              border: Border.all(
                color: Colors
                    .grey
                    .shade300,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                12,
              ),
            ),
            child: Row(
              children: [

                const Icon(
                  Icons.schedule,
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    _scheduledDateTime ==
                            null
                        ? "Select date & time"
                        : "${_scheduledDateTime!.day}/${_scheduledDateTime!.month}/${_scheduledDateTime!.year} "
                          "${_scheduledDateTime!.hour.toString().padLeft(2, '0')}:"
                          "${_scheduledDateTime!.minute.toString().padLeft(2, '0')}",
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  ),
),

            SizedBox(
              width:
                  double.infinity,
              height: 52,
              child:
                  ElevatedButton.icon(
                onPressed: () async {

                  await _sendNotification();

                  if (mounted) {
                    Navigator.pop(
                      context,
                    );
                  }
                },

                icon: const Icon(
                  Icons.send,
                ),

                label: const Text(
                  "Send Notification",
                ),

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFFB5838D,
                  ),
                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),
          ],
        ),
      );
    },
  );
}

  Color _statusColor(
    String status,
  ) {

    switch (status) {

      case "sent":
        return Colors.green;

      case "failed":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F4F4),

      body: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
  mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
  children: [

    const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          "Push Notifications",
          style: TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        SizedBox(height: 4),

        Text(
          "Send notifications to app users",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    ),

    ElevatedButton.icon(
      onPressed:
          _showCreateNotificationSheet,

      icon: const Icon(
        Icons.add,
      ),

      label: const Text(
        "New Notification",
      ),

      style:
          ElevatedButton.styleFrom(
        backgroundColor:
            const Color(
          0xFFB5838D,
        ),
        foregroundColor:
            Colors.white,
      ),
    ),
  ],
),

            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  border: Border.all(
                    color: Colors
                        .grey
                        .shade200,
                  ),
                ),

                child: Column(
                  children: [

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            20,
                        vertical: 18,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFFDFBFB,
                        ),

                        borderRadius:
                            const BorderRadius.only(
                          topLeft:
                              Radius.circular(
                            18,
                          ),
                          topRight:
                              Radius.circular(
                            18,
                          ),
                        ),
                      ),

                      child:
                          const Row(
                        children: [

                          Expanded(
                            flex: 2,
                            child: Text(
                              "Title",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 3,
                            child: Text(
                              "Message",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "Status",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "Date",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child:
                          StreamBuilder<
                              List<
                                  NotificationModel>>(
                        stream:
                            _firestore
                                .notificationsStream(),

                        builder: (
                          context,
                          snapshot,
                        ) {

                          if (!snapshot
                              .hasData) {

                            return const Center(
                              child:
                                  CircularProgressIndicator(),
                            );
                          }

                          final notifications =
                              snapshot.data!;

                          if (notifications
                              .isEmpty) {

                            return const Center(
                              child: Text(
                                "No notifications found",
                              ),
                            );
                          }

                          return ListView
                              .builder(

                            itemCount:
                                notifications
                                    .length,

                            itemBuilder:
                                (
                              context,
                              index,
                            ) {

                              final item =
                                  notifications[
                                      index];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      20,
                                  vertical:
                                      16,
                                ),

                                child: Row(
                                  children: [

                                    Expanded(
                                      flex: 2,
                                      child:
                                          Text(
                                        item
                                            .title,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 3,
                                      child:
                                          Text(
                                        item
                                            .body,
                                        maxLines:
                                            2,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    ),

                                    Expanded(
                                      child:
                                          Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              10,
                                          vertical:
                                              6,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              _statusColor(item.status)
                                                  .withOpacity(
                                            0.1,
                                          ),

                                          borderRadius:
                                              BorderRadius.circular(
                                            20,
                                          ),
                                        ),

                                        child:
                                            Text(
                                          item
                                              .status
                                              .toUpperCase(),

                                          textAlign:
                                              TextAlign.center,

                                          style:
                                              TextStyle(
                                            color:
                                                _statusColor(
                                              item.status,
                                            ),

                                            fontWeight:
                                                FontWeight.w600,

                                            fontSize:
                                                12,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child:
                                          Text(
                                        item.createdAt ==
                                                null
                                            ? "-"
                                            : "${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}",
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}