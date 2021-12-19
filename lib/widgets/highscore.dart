import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonlander/database/database.dart';
import 'package:moonlander/game_state.dart';
import 'package:moonlander/main.dart';

/// Overview widget of all the scores.
class HighscoreOverview extends StatefulWidget {
/// Overview widget of all the scores.
  const HighscoreOverview(this.game, {Key? key}) : super(key: key);

  /// Reference to the game.
  final MoonlanderGame game;

  @override
  _HighscoreOverviewState createState() => _HighscoreOverviewState();
}

class _HighscoreOverviewState extends State<HighscoreOverview> {
  List<GetTopTenForSeedResult>? scores;
  late final DateFormat dateTimeFormatter;
  Future<void> loadData() async {
    scores = await GameState.database.getTopTenForSeed(GameState.seed).get();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    dateTimeFormatter = DateFormat.yMd().add_jm();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          child: Material(
            child: Container(
              width: 320,
              height: 320,
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 15,
                    ),
                    child: Wrap(
                      children: [
                        Text(
                          'Seed ${GameState.seed}',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                  _content(),
                  ElevatedButton(
                    onPressed: () {
                      widget.game.overlays.remove('highscore');
                      widget.game.overlays.add('pause');
                    },
                    child: const Text('OK'),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _content() {
    if (scores == null) {
      return const CircularProgressIndicator();
    } else if (scores != null && scores!.isEmpty) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.gamepad,
              size: 45,
              color: Colors.blueGrey,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 15,
              ),
            ),
            Text('No scores for this seed yet!'),
          ],
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            final result = scores![index];
            return ListTile(
              title: Text('Score ${result.score.toString()}'),
              subtitle: Text(
                'From ${dateTimeFormatter.format(
                  result.creationDate,
                )}',
              ),
            );
          },
          itemCount: scores?.length,
        ),
      );
    }
  }
}
