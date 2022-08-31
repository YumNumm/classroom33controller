// ignore_for_file: prefer_const_constructors_in_immutables

import 'dart:convert';
import 'dart:developer';

import 'package:controller/api/supabase_api.dart';
import 'package:controller/main.dart';
import 'package:controller/provider/db_provider.dart';
import 'package:controller/provider/user_provider.dart';
import 'package:controller/schema/state/state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class TopPage extends HookConsumerWidget {
  const TopPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controller'),
        elevation: 8,
        backgroundColor: colorFromPosision(
          ref.watch(selectedDeviceIdProvider.notifier).state!,
        )[0]
            .withAlpha(127),
      ),
      body: ref.watch(deviceStateStreamProvider).when<Widget>(
            data: (deviceState) {
              log(deviceState.toString(), name: 'deviceStateStreamProvider');

              /// [1] DeviceState.waiting -> 待機画面(OnWaitingPage)
              /// [2] DeviceState.starting && isAccepted -> 開始待ち画面(OnStartingWaitPage)
              /// [3] DeviceState.starting && !isAccepted -> 実行許可画面(OnStartingPage)
              /// [4] DeviceState.running && userId != null-> カウンター画面(OnCounterPage)
              /// [5] DeviceState.running && userId == null-> 待機画面(OnOthersRunningPage)
              if (deviceState.state == DeviceState.waiting) {
                return const OnWaitingPage();
              }

              switch (deviceState.state) {
                case DeviceState.starting:
                  if (deviceState.isAccepted == true) {
                    return const OnStartingWaitPage();
                  } else {
                    return OnStartingPage(deviceState: deviceState);
                  }
                case DeviceState.running:
                  if (deviceState.userId != null) {
                    return const OnCounterPage();
                  } else {
                    return const OnOthersRunningPage();
                  }
                case DeviceState.waiting:
                  break;
              }

              if (deviceState.userId == null) {
                return const Center(
                  child: Text('User not found'),
                );
              }
              return ref.watch(userProvider(deviceState.userId!)).when<Widget>(
                    error: (error, stackTrace) => Text(error.toString()),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    data: (userData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            const JsonEncoder.withIndent('  ')
                                .convert(deviceState),
                          ),
                          const Divider(),
                          Text(
                            const JsonEncoder.withIndent('  ')
                                .convert(userData.toJson()),
                          ),
                        ],
                      );
                    },
                  );
            },
            error: (error, stackTrace) => Center(child: Text('error: $error')),
            loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
    );
  }
}

class OnWaitingPage extends StatelessWidget {
  const OnWaitingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('全体待機中...'),
          SizedBox(height: 8),
          CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }
}

class OnStartingWaitPage extends StatelessWidget {
  const OnStartingWaitPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('他のユーザの開始許可・マスターの開始を待っています...'),
          SizedBox(height: 8),
          CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }
}

class OnStartingPage extends ConsumerWidget {
  OnStartingPage({super.key, required this.deviceState});
  final DeviceStateItem deviceState;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (deviceState.userId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 8,
            clipBehavior: Clip.antiAlias,
            shadowColor: Colors.blue.withAlpha(70),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'ユーザID: なし',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ライドID: なし',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                SupabaseApi.updateDeviceStateItem(
                                  deviceState.state,
                                  deviceState.position,
                                  isAccepted: true,
                                );
                              },
                              label: const Text('開始許可'),
                              icon: const Icon(Icons.check),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: FloatingActionButton.extended(
                              onPressed: () async {
                                await showDialog<void>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('ユーザ変更'),
                                      content: ref
                                          .watch(usersFutureProvider)
                                          .when<Widget>(
                                            error: (error, stackTrace) =>
                                                Text(error.toString()),
                                            loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            data: (users) {
                                              return SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      title:
                                                          const Text('ユーザなし'),
                                                      leading: const Icon(
                                                        Icons.person,
                                                        color: Colors.grey,
                                                      ),
                                                      onTap: () {
                                                        SupabaseApi
                                                            .updateDeviceStateItem(
                                                          deviceState.state,
                                                          deviceState.position,
                                                          userId: -1,
                                                        );
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    const Divider(),
                                                    for (final user in users)
                                                      ListTile(
                                                        title: Text(
                                                          'ユーザ: ${user.id}',
                                                        ),
                                                        subtitle: Text(
                                                          'ライドID: ${user.rideId}\n'
                                                          '${DateFormat('yyyy/MM/dd HH:mm:ss').format(user.createdAt.toLocal())}',
                                                        ),
                                                        onTap: () {
                                                          SupabaseApi
                                                              .updateDeviceStateItem(
                                                            deviceState.state,
                                                            deviceState
                                                                .position,
                                                            userId: user.id,
                                                          );
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        leading: const Icon(
                                                          Icons.person,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                    );
                                  },
                                );
                              },
                              label: const Text('変更する'),
                              icon: const Icon(Icons.edit),
                              backgroundColor: Colors.blueGrey,
                              elevation: 0,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Text(
            const JsonEncoder.withIndent('  ').convert(deviceState),
          ),
          const Divider(),
        ],
      );
    } else {
      return ref.watch(userProvider(deviceState.userId!)).when<Widget>(
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const Center(child: CircularProgressIndicator()),
            data: (userData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 8,
                    clipBehavior: Clip.antiAlias,
                    shadowColor: Colors.blue.withAlpha(70),
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ユーザID: ${userData.id}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'ライドID: ${userData.rideId}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: FloatingActionButton.extended(
                                      onPressed: () {
                                        SupabaseApi.updateDeviceStateItem(
                                          deviceState.state,
                                          deviceState.position,
                                          isAccepted: true,
                                        );
                                      },
                                      label: const Text('開始許可'),
                                      icon: const Icon(Icons.check),
                                    ),
                                  ),
                                  FloatingActionButton.extended(
                                    onPressed: () async {
                                      await showDialog<void>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('ユーザ変更'),
                                            content: ref
                                                .watch(usersFutureProvider)
                                                .when<Widget>(
                                                  error: (error, stackTrace) =>
                                                      Text(error.toString()),
                                                  loading: () => const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                  data: (users) {
                                                    return SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          ListTile(
                                                            title: const Text(
                                                              'ユーザなし',
                                                            ),
                                                            leading: const Icon(
                                                              Icons.person,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            onTap: () {
                                                              SupabaseApi
                                                                  .updateDeviceStateItem(
                                                                deviceState
                                                                    .state,
                                                                deviceState
                                                                    .position,
                                                                userId: -1,
                                                              );
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
                                                            },
                                                          ),
                                                          const Divider(),
                                                          for (final user
                                                              in users)
                                                            ListTile(
                                                              title: Text(
                                                                'ユーザ: ${user.id}',
                                                              ),
                                                              subtitle: Text(
                                                                'ライドID: ${user.rideId}\n'
                                                                '${DateFormat('yyyy/MM/dd HH:mm:ss').format(user.createdAt.toLocal())}',
                                                              ),
                                                              onTap: () {
                                                                SupabaseApi
                                                                    .updateDeviceStateItem(
                                                                  deviceState
                                                                      .state,
                                                                  deviceState
                                                                      .position,
                                                                  userId:
                                                                      user.id,
                                                                );
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                              },
                                                              leading:
                                                                  const Icon(
                                                                Icons.person,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                          );
                                        },
                                      );
                                    },
                                    label: const Text('変更する'),
                                    icon: const Icon(Icons.edit),
                                    backgroundColor: Colors.blueGrey,
                                    elevation: 0,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    const JsonEncoder.withIndent('  ').convert(deviceState),
                  ),
                  const Divider(),
                  Text(
                    const JsonEncoder.withIndent('  ')
                        .convert(userData.toJson()),
                  ),
                ],
              );
            },
          );
    }
  }
}

class OnCounterPage extends StatelessWidget {
  const OnCounterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('カウント中...'),
          SizedBox(height: 8),
          CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }
}

class OnOthersRunningPage extends StatelessWidget {
  const OnOthersRunningPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('他のユーザが実行中...'),
          SizedBox(height: 8),
          CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }
}
