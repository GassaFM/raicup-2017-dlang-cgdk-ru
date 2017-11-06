module my_strategy;

import model;
import strategy;

final class MyStrategy : Strategy
{
    void move (immutable Player me, immutable World world,
        immutable Game game, Move move)
    {
        if (world.tickIndex == 0)
        {
            move.action = ActionType.clearAndSelect;
            move.right = world.width;
            move.bottom = world.height;
            return;
        }

        if (world.tickIndex == 1)
        {
            move.action = ActionType.move;
            move.x = world.width / 2.0;
            move.y = world.height / 2.0;
        }
    }
}
